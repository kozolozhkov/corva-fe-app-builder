#!/usr/bin/env bash
set -euo pipefail

ROUTES_FILE="${1:-/Users/kzolozhkov/corva/core/corva-api/config/routes.rb}"

if [[ ! -f "$ROUTES_FILE" ]]; then
  echo "Missing file: $ROUTES_FILE" >&2
  exit 1
fi

awk -v src_file="$ROUTES_FILE" '
  function normalize(path, out) {
    out = path
    gsub(/\/+/, "/", out)
    sub(/\/$/, "", out)
    if (out == "") {
      out = "/"
    }
    return out
  }

  function wants_path(path) {
    return path ~ /(^|\/)(assets|wells|rigs|users|programs|pads|frac_fleets|drillout_units|intervention_units|companies|company|picklists|preferences)(\/|$)|active_asset_ids|recent_assets|autocomplete|clusters|ancestor_ids|reruns|app_wells|settings|current/
  }

  function wants_resource(resource) {
    return resource ~ /^(assets|wells|rigs|users|programs|pads|frac_fleets|drillout_units|intervention_units|companies|picklists)$/
  }

  function emit(endpoint, line_no, note, key) {
    endpoint = normalize(endpoint)
    key = "GET\t" endpoint
    if (!seen[key]) {
      seen[key] = 1
      printf "GET\t%s\t%s:%d\t%s\n", endpoint, src_file, line_no, note
    }
  }

  function derive_resources(resource, line, line_no, base, include_index, include_show, param_key) {
    if (!wants_resource(resource)) {
      return
    }

    include_index = 1
    include_show = 1

    if (line ~ /only:[^\n]*/) {
      include_index = (line ~ /index/)
      include_show = (line ~ /show/)
    }

    if (line ~ /except:[^\n]*/) {
      if (line ~ /index/) {
        include_index = 0
      }
      if (line ~ /show/) {
        include_show = 0
      }
    }

    param_key = "id"
    if (match(line, /param:[[:space:]]*:[a-z_]+/)) {
      param_key = substr(line, RSTART, RLENGTH)
      sub(/^param:[[:space:]]*:/, "", param_key)
    }

    base = ns_prefix "/" resource

    if (include_index) {
      emit(base, line_no, "derived resources#index")
    }

    if (include_show) {
      emit(base "/:" param_key, line_no, "derived resources#show")
    }
  }

  function get_token(line, token) {
    token = ""

    if (match(line, /get[[:space:]]+\047[^\047]+\047/)) {
      token = substr(line, RSTART, RLENGTH)
      sub(/^get[[:space:]]+\047/, "", token)
      sub(/\047$/, "", token)
      return token
    }

    if (match(line, /get[[:space:]]+:[a-z_]+/)) {
      token = substr(line, RSTART, RLENGTH)
      sub(/^get[[:space:]]+:/, "", token)
      return token
    }

    return token
  }

  BEGIN {
    ns_prefix = ""
    top_resource = ""
    top_resource_track = 0
    top_resource_scope = ""
  }

  {
    line = $0
    line_no = NR

    if (line ~ /^[[:space:]]*namespace :v1([[:space:]]|,)/) {
      ns_prefix = "/v1"
      top_resource = ""
      top_resource_track = 0
      top_resource_scope = ""
    } else if (line ~ /^[[:space:]]*namespace :v2([[:space:]]|,)/) {
      ns_prefix = "/v2"
      top_resource = ""
      top_resource_track = 0
      top_resource_scope = ""
    }

    if (match(line, /^    resources :[a-z_]+/)) {
      resource = substr(line, RSTART + length("    resources :"))
      sub(/[^a-z_].*$/, "", resource)

      derive_resources(resource, line, line_no)

      if (line ~ / do[[:space:]]*$/ && wants_resource(resource)) {
        top_resource = resource
        top_resource_track = 1
        top_resource_scope = ""
      } else {
        top_resource = ""
        top_resource_track = 0
        top_resource_scope = ""
      }
    }

    if (top_resource_track && line ~ /^    end[[:space:]]*$/) {
      top_resource = ""
      top_resource_track = 0
      top_resource_scope = ""
    }

    if (top_resource_track && line ~ /^      member do[[:space:]]*$/) {
      top_resource_scope = "member"
    } else if (top_resource_track && line ~ /^      collection do[[:space:]]*$/) {
      top_resource_scope = "collection"
    } else if (top_resource_track && top_resource_scope != "" && line ~ /^      end[[:space:]]*$/) {
      top_resource_scope = ""
    }

    if (line ~ /^    get[[:space:]]/) {
      raw = get_token(line)
      if (raw != "" && wants_path(raw)) {
        emit(ns_prefix "/" raw, line_no, "explicit get")
      }
    }

    if (top_resource_track && line ~ /^      get[[:space:]]/) {
      rel = get_token(line)
      if (rel == "") {
        next
      }

      if (line ~ /on:[[:space:]]*:member/) {
        emit(ns_prefix "/" top_resource "/:id/" rel, line_no, "derived member get")
      } else if (line ~ /on:[[:space:]]*:collection/) {
        emit(ns_prefix "/" top_resource "/" rel, line_no, "derived collection get")
      }
    }

    if (top_resource_track && top_resource_scope != "" && line ~ /^        get[[:space:]]/) {
      rel = get_token(line)
      if (rel == "") {
        next
      }

      if (top_resource_scope == "member") {
        emit(ns_prefix "/" top_resource "/:id/" rel, line_no, "derived member-scope get")
      } else if (top_resource_scope == "collection") {
        emit(ns_prefix "/" top_resource "/" rel, line_no, "derived collection-scope get")
      }
    }
  }
' "$ROUTES_FILE" | sort -t $'\t' -k2,2
