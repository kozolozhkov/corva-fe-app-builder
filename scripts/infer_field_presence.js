#!/usr/bin/env node

const fs = require('fs');

const inputPath = process.argv[2] || null;
let raw;

try {
  raw = inputPath ? fs.readFileSync(inputPath, 'utf8') : fs.readFileSync(0, 'utf8');
} catch (error) {
  console.error(`Failed to read input: ${error.message}`);
  process.exit(1);
}

let parsed;
try {
  parsed = JSON.parse(raw);
} catch (error) {
  console.error(`Input is not valid JSON: ${error.message}`);
  process.exit(1);
}

const normalizeRecords = value => {
  if (Array.isArray(value)) return value;
  if (value && typeof value === 'object') {
    if (Array.isArray(value.data)) return value.data;
    if (Array.isArray(value.records)) return value.records;
    return [value];
  }
  return [];
};

const records = normalizeRecords(parsed);
if (records.length === 0) {
  console.error('No records found. Provide a JSON array or an object with array at "data" or "records".');
  process.exit(1);
}

const inferType = value => {
  if (value === null) return 'null';
  if (Array.isArray(value)) return 'array';
  if (typeof value === 'number') return Number.isInteger(value) ? 'integer' : 'number';
  if (typeof value === 'string') return 'string';
  if (typeof value === 'boolean') return 'boolean';
  if (typeof value === 'object') return 'object';
  return typeof value;
};

const stats = new Map();

const getEntry = path => {
  if (!stats.has(path)) {
    stats.set(path, {
      presentRecords: 0,
      nullRecords: 0,
      nonNullRecords: 0,
      types: new Set(),
    });
  }
  return stats.get(path);
};

const mark = (path, value, seenPresent, seenNull, seenNonNull) => {
  const entry = getEntry(path);

  if (!seenPresent.has(path)) {
    entry.presentRecords += 1;
    seenPresent.add(path);
  }

  if (value === null) {
    if (!seenNull.has(path)) {
      entry.nullRecords += 1;
      seenNull.add(path);
    }
  } else {
    if (!seenNonNull.has(path)) {
      entry.nonNullRecords += 1;
      seenNonNull.add(path);
    }
  }

  entry.types.add(inferType(value));
};

const walk = (value, path, seenPresent, seenNull, seenNonNull) => {
  mark(path, value, seenPresent, seenNull, seenNonNull);

  if (value === null) return;

  if (Array.isArray(value)) {
    value.forEach(item => {
      if (item && typeof item === 'object') {
        walk(item, `${path}[]`, seenPresent, seenNull, seenNonNull);
      }
    });
    return;
  }

  if (value && typeof value === 'object') {
    Object.keys(value).forEach(key => {
      const childPath = path ? `${path}.${key}` : key;
      walk(value[key], childPath, seenPresent, seenNull, seenNonNull);
    });
  }
};

records.forEach(record => {
  if (!record || typeof record !== 'object') return;
  const seenPresent = new Set();
  const seenNull = new Set();
  const seenNonNull = new Set();

  Object.keys(record).forEach(key => {
    walk(record[key], key, seenPresent, seenNull, seenNonNull);
  });
});

const total = records.length;

const rows = Array.from(stats.entries())
  .sort((a, b) => a[0].localeCompare(b[0]))
  .map(([field, entry]) => {
    const ratio = entry.presentRecords / total;
    let nullability = 'non-null in sample';
    if (entry.nullRecords > 0 && entry.nonNullRecords > 0) {
      nullability = 'nullable in sample';
    } else if (entry.nullRecords > 0 && entry.nonNullRecords === 0) {
      nullability = 'always null in sample';
    }

    return {
      field,
      presence_ratio: Number(ratio.toFixed(4)),
      present_records: entry.presentRecords,
      total_records: total,
      types: Array.from(entry.types).sort().join('|'),
      nullability,
    };
  });

console.log('field\tpresence_ratio\tpresent_records\ttotal_records\ttypes\tnullability');
rows.forEach(row => {
  console.log(
    `${row.field}\t${row.presence_ratio}\t${row.present_records}\t${row.total_records}\t${row.types}\t${row.nullability}`
  );
});
