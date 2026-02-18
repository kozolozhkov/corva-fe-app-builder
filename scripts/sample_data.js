#!/usr/bin/env node

'use strict';

const fs = require('fs');
const path = require('path');

const NO_DATA_MESSAGE =
  'No data was found for this collection and asset in the selected environment.';

function usage() {
  console.log(`Usage:
  sample_data.js [options]

Options:
  --app-root <path>          App root directory (default: current directory)
  --token <token>            Bearer token (overrides env and .env.local)
  --base-url <url>           Data API base URL (required if env is not set)
  --provider <name>          Provider (default: corva)
  --collection <name>        Collection (required)
  --asset-id <id>            Asset id (required unless --query-json is used)
  --query-field <path>       Query key for asset id (default: asset_id)
  --query-json <json>        Full query override JSON
  --sort-json <json>         Sort JSON (default: {"timestamp":-1})
  --limit <n>                Limit (default: 10)
  --fields <csv>             Optional fields selector
  --raw-out <path>           Write raw response JSON to file
  --summary-out <path>       Write summary JSON to file
  --help                     Show this help
`);
}

function parseArgs(argv) {
  const out = {};
  for (let i = 2; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--help' || arg === '-h') {
      out.help = true;
      continue;
    }
    if (!arg.startsWith('--')) {
      throw new Error(`Unknown positional argument: ${arg}`);
    }

    const key = arg.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      throw new Error(`Missing value for argument: ${arg}`);
    }
    out[key] = next;
    i += 1;
  }
  return out;
}

function parseEnvFile(filePath) {
  const env = {};
  if (!fs.existsSync(filePath)) {
    return env;
  }

  const lines = fs.readFileSync(filePath, 'utf8').split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) {
      continue;
    }

    const eqIdx = trimmed.indexOf('=');
    if (eqIdx === -1) {
      continue;
    }

    const key = trimmed.slice(0, eqIdx).trim();
    let value = trimmed.slice(eqIdx + 1).trim();

    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }

    env[key] = value;
  }

  return env;
}

function normalizeRecords(payload) {
  if (Array.isArray(payload)) {
    return payload;
  }

  if (payload && typeof payload === 'object') {
    if (Array.isArray(payload.data)) {
      return payload.data;
    }
    if (Array.isArray(payload.records)) {
      return payload.records;
    }
    return [payload];
  }

  return [];
}

function inferType(value) {
  if (value === null) return 'null';
  if (Array.isArray(value)) return 'array';
  if (typeof value === 'number') return Number.isInteger(value) ? 'integer' : 'number';
  if (typeof value === 'string') return 'string';
  if (typeof value === 'boolean') return 'boolean';
  if (typeof value === 'object') return 'object';
  return typeof value;
}

function summarizeFields(records) {
  const stats = new Map();

  function getEntry(field) {
    if (!stats.has(field)) {
      stats.set(field, {
        presentRecords: 0,
        nullRecords: 0,
        nonNullRecords: 0,
        types: new Set(),
      });
    }
    return stats.get(field);
  }

  function mark(field, value, seenPresent, seenNull, seenNonNull) {
    const entry = getEntry(field);

    if (!seenPresent.has(field)) {
      entry.presentRecords += 1;
      seenPresent.add(field);
    }

    if (value === null) {
      if (!seenNull.has(field)) {
        entry.nullRecords += 1;
        seenNull.add(field);
      }
    } else {
      if (!seenNonNull.has(field)) {
        entry.nonNullRecords += 1;
        seenNonNull.add(field);
      }
    }

    entry.types.add(inferType(value));
  }

  function walk(value, field, seenPresent, seenNull, seenNonNull) {
    mark(field, value, seenPresent, seenNull, seenNonNull);

    if (value === null) {
      return;
    }

    if (Array.isArray(value)) {
      value.forEach(item => {
        if (item && typeof item === 'object') {
          walk(item, `${field}[]`, seenPresent, seenNull, seenNonNull);
        }
      });
      return;
    }

    if (value && typeof value === 'object') {
      Object.keys(value).forEach(key => {
        const childField = field ? `${field}.${key}` : key;
        walk(value[key], childField, seenPresent, seenNull, seenNonNull);
      });
    }
  }

  records.forEach(record => {
    if (!record || typeof record !== 'object') {
      return;
    }

    const seenPresent = new Set();
    const seenNull = new Set();
    const seenNonNull = new Set();

    Object.keys(record).forEach(key => {
      walk(record[key], key, seenPresent, seenNull, seenNonNull);
    });
  });

  const total = records.length;

  return Array.from(stats.entries())
    .sort((a, b) => a[0].localeCompare(b[0]))
    .map(([field, entry]) => {
      let nullability = 'non-null in sample';
      if (entry.nullRecords > 0 && entry.nonNullRecords > 0) {
        nullability = 'nullable in sample';
      } else if (entry.nullRecords > 0 && entry.nonNullRecords === 0) {
        nullability = 'always null in sample';
      }

      return {
        field,
        meaning_confidence: 'inferred',
        presence_ratio: Number((entry.presentRecords / total).toFixed(4)),
        present_records: entry.presentRecords,
        total_records: total,
        inferred_types: Array.from(entry.types).sort(),
        nullability,
      };
    });
}

function parseMaybeNumber(value) {
  if (/^-?\d+$/.test(value)) {
    return Number(value);
  }
  return value;
}

async function run() {
  const args = parseArgs(process.argv);
  if (args.help) {
    usage();
    return;
  }

  const appRoot = path.resolve(args['app-root'] || process.cwd());
  const envFile = path.join(appRoot, '.env.local');
  const fileEnv = parseEnvFile(envFile);

  const token = args.token || process.env.CORVA_BEARER_TOKEN || fileEnv.CORVA_BEARER_TOKEN;
  const baseUrlRaw = args['base-url'] || process.env.CORVA_DATA_API_BASE_URL || fileEnv.CORVA_DATA_API_BASE_URL;
  const provider = args.provider || process.env.CORVA_PROVIDER || fileEnv.CORVA_PROVIDER || 'corva';
  const collection = args.collection || process.env.CORVA_COLLECTION || fileEnv.CORVA_COLLECTION;
  const assetId = args['asset-id'] || process.env.CORVA_ASSET_ID || fileEnv.CORVA_ASSET_ID;

  const queryField = args['query-field'] || 'asset_id';
  const queryJson = args['query-json'];
  const sortJson = args['sort-json'] || '{"timestamp":-1}';
  const limitRaw = args.limit || process.env.CORVA_LIMIT || '10';
  const fields = args.fields || '';

  if (!token) {
    throw new Error('Missing bearer token. Pass --token or set CORVA_BEARER_TOKEN in .env.local.');
  }
  if (!baseUrlRaw) {
    throw new Error('Missing base URL. Pass --base-url or set CORVA_DATA_API_BASE_URL.');
  }
  if (!collection) {
    throw new Error('Missing collection. Pass --collection or set CORVA_COLLECTION.');
  }

  const limit = Number(limitRaw);
  if (!Number.isInteger(limit) || limit <= 0) {
    throw new Error('--limit must be a positive integer.');
  }

  let query;
  if (queryJson) {
    try {
      query = JSON.parse(queryJson);
    } catch (error) {
      throw new Error(`--query-json must be valid JSON: ${error.message}`);
    }
  } else {
    if (!assetId) {
      throw new Error('Missing asset id. Pass --asset-id or use --query-json.');
    }
    query = { [queryField]: parseMaybeNumber(String(assetId)) };
  }

  let sort;
  try {
    sort = JSON.parse(sortJson);
  } catch (error) {
    throw new Error(`--sort-json must be valid JSON: ${error.message}`);
  }

  const baseUrl = baseUrlRaw.replace(/\/+$/, '');
  const endpoint = `${baseUrl}/api/v1/data/${provider}/${collection}/`;

  const params = new URLSearchParams();
  params.set('limit', String(limit));
  params.set('skip', '0');
  params.set('query', JSON.stringify(query));
  params.set('sort', JSON.stringify(sort));
  if (fields) {
    params.set('fields', fields);
  }

  if (typeof fetch !== 'function') {
    throw new Error('Global fetch is unavailable. Use Node.js 18+ or newer.');
  }

  const response = await fetch(`${endpoint}?${params.toString()}`, {
    method: 'GET',
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${token}`,
    },
  });

  const responseText = await response.text();
  if (!response.ok) {
    throw new Error(`Sample fetch failed (${response.status}): ${responseText.slice(0, 600)}`);
  }

  let payload;
  try {
    payload = JSON.parse(responseText);
  } catch (error) {
    throw new Error(`Response is not valid JSON: ${error.message}`);
  }

  const records = normalizeRecords(payload);
  const fieldsSummary = records.length > 0 ? summarizeFields(records) : [];

  const output = {
    status: records.length > 0 ? 'has-data' : 'no-data',
    endpoint,
    request: {
      provider,
      collection,
      limit,
      query,
      sort,
      fields: fields || null,
    },
    records_count: records.length,
    no_data_message: records.length > 0 ? null : NO_DATA_MESSAGE,
    fields: fieldsSummary,
  };

  if (args['raw-out']) {
    fs.writeFileSync(path.resolve(args['raw-out']), JSON.stringify(payload, null, 2));
  }
  if (args['summary-out']) {
    fs.writeFileSync(path.resolve(args['summary-out']), JSON.stringify(output, null, 2));
  }

  process.stdout.write(`${JSON.stringify(output, null, 2)}\n`);
}

run().catch(error => {
  console.error(error.message);
  process.exit(1);
});
