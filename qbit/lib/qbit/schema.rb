# frozen_string_literal: true

module Qbit
  SCHEMAS = {
    "torrent list" => {
      output: "ndjson",
      record: {
        hash:           { type: "string",  note: "40-char SHA1 — use as --hash / --hashes input" },
        name:           { type: "string" },
        state:          { type: "string",  enum: %w[downloading uploading stalledDL stalledUP
                                                     pausedDL pausedUP checkingDL checkingUP
                                                     checkingResumeData allocating metaDL
                                                     queuedDL queuedUP moving error unknown] },
        progress:       { type: "number",  range: "0.0–1.0" },
        size:           { type: "integer", unit: "bytes", note: "selected-file size" },
        total_size:     { type: "integer", unit: "bytes", note: "all-file size" },
        dlspeed:        { type: "integer", unit: "bytes/s" },
        upspeed:        { type: "integer", unit: "bytes/s" },
        downloaded:     { type: "integer", unit: "bytes" },
        uploaded:       { type: "integer", unit: "bytes" },
        ratio:          { type: "number" },
        eta:            { type: "integer", unit: "seconds", note: "8640000 = unknown" },
        category:       { type: "string" },
        tags:           { type: "string",  note: "comma-separated tag names" },
        save_path:      { type: "string" },
        content_path:   { type: "string" },
        added_on:       { type: "integer", format: "unix_timestamp" },
        completion_on:  { type: "integer", format: "unix_timestamp", note: "-1 if incomplete" },
        last_activity:  { type: "integer", format: "unix_timestamp" },
        tracker:        { type: "string",  note: "URL of current tracker" },
        trackers_count: { type: "integer" },
        num_seeds:      { type: "integer" },
        num_leechs:     { type: "integer" },
        num_complete:   { type: "integer", note: "seeds in swarm" },
        num_incomplete: { type: "integer", note: "peers in swarm" },
        priority:       { type: "integer", note: "0 if not queued" },
        dl_limit:       { type: "integer", unit: "bytes/s", note: "-1 = unlimited" },
        up_limit:       { type: "integer", unit: "bytes/s", note: "-1 = unlimited" },
        force_start:    { type: "boolean" },
        seq_dl:         { type: "boolean" },
        auto_tmm:       { type: "boolean" },
        magnet_uri:     { type: "string" },
      }
    },

    "torrent get" => {
      output: "json",
      note: "hash field is injected by the CLI (not returned by the API itself)",
      record: {
        hash:               { type: "string" },
        name:               { type: "string" },
        save_path:          { type: "string" },
        creation_date:      { type: "integer", format: "unix_timestamp" },
        comment:            { type: "string" },
        total_size:         { type: "integer", unit: "bytes" },
        total_wasted:       { type: "integer", unit: "bytes" },
        nb_connections:     { type: "integer" },
        nb_connections_limit: { type: "integer" },
        peers:              { type: "integer" },
        peers_total:        { type: "integer" },
        seeds:              { type: "integer" },
        seeds_total:        { type: "integer" },
        share_ratio:        { type: "number" },
        time_elapsed:       { type: "integer", unit: "seconds" },
        seeding_time:       { type: "integer", unit: "seconds" },
        eta:                { type: "integer", unit: "seconds" },
        dl_speed:           { type: "integer", unit: "bytes/s" },
        dl_speed_avg:       { type: "integer", unit: "bytes/s" },
        up_speed:           { type: "integer", unit: "bytes/s" },
        up_speed_avg:       { type: "integer", unit: "bytes/s" },
        dl_limit:           { type: "integer", unit: "bytes/s" },
        up_limit:           { type: "integer", unit: "bytes/s" },
        total_downloaded:   { type: "integer", unit: "bytes" },
        total_uploaded:     { type: "integer", unit: "bytes" },
        addition_date:      { type: "integer", format: "unix_timestamp" },
        completion_date:    { type: "integer", format: "unix_timestamp" },
        created_by:         { type: "string" },
        is_private:         { type: "boolean" },
        piece_size:         { type: "integer", unit: "bytes" },
        pieces_num:         { type: "integer" },
        pieces_have:        { type: "integer" },
      }
    },

    "torrent files" => {
      output: "ndjson",
      record: {
        index:        { type: "integer", note: "file index within the torrent" },
        name:         { type: "string",  note: "relative path within torrent" },
        size:         { type: "integer", unit: "bytes" },
        progress:     { type: "number",  range: "0.0–1.0" },
        priority:     { type: "integer", enum: [0, 1, 6, 7],
                        note: "0=skip, 1=normal, 6=high, 7=max" },
        is_seed:      { type: "boolean" },
        piece_range:  { type: "array",   items: "integer" },
        availability: { type: "number" },
      }
    },

    "torrent trackers" => {
      output: "ndjson",
      record: {
        url:            { type: "string" },
        status:         { type: "integer", enum: [0, 1, 2, 3, 4],
                          note: "0=disabled, 1=not_contacted, 2=working, 3=updating, 4=not_working" },
        tier:           { type: "integer" },
        num_peers:      { type: "integer" },
        num_seeds:      { type: "integer" },
        num_leeches:    { type: "integer" },
        num_downloaded: { type: "integer" },
        msg:            { type: "string" },
      }
    },

    "torrent peers" => {
      output: "ndjson",
      note: "address field (ip:port) is injected by the CLI from the peers map key",
      record: {
        address:      { type: "string",  note: "ip:port — unique peer identifier" },
        ip:           { type: "string" },
        port:         { type: "integer" },
        client:       { type: "string" },
        connection:   { type: "string" },
        country:      { type: "string" },
        country_code: { type: "string" },
        progress:     { type: "number",  range: "0.0–1.0" },
        dl_speed:     { type: "integer", unit: "bytes/s" },
        up_speed:     { type: "integer", unit: "bytes/s" },
        downloaded:   { type: "integer", unit: "bytes" },
        uploaded:     { type: "integer", unit: "bytes" },
        flags:        { type: "string" },
        flags_desc:   { type: "string" },
        relevance:    { type: "number" },
      }
    },

    "category list" => {
      output: "ndjson",
      note: "API returns a name→object map; CLI unwraps to NDJSON of the values",
      record: {
        name:      { type: "string" },
        savePath:  { type: "string" },
      }
    },

    "tag list" => {
      output: "ndjson",
      note: "API returns a JSON array of strings; CLI wraps each in {name:}",
      record: {
        name: { type: "string" },
      }
    },

    "transfer info" => {
      output: "json",
      record: {
        dl_info_speed:     { type: "integer", unit: "bytes/s" },
        dl_info_data:      { type: "integer", unit: "bytes",   note: "downloaded this session" },
        up_info_speed:     { type: "integer", unit: "bytes/s" },
        up_info_data:      { type: "integer", unit: "bytes",   note: "uploaded this session" },
        dl_rate_limit:     { type: "integer", unit: "bytes/s", note: "0 = unlimited" },
        up_rate_limit:     { type: "integer", unit: "bytes/s", note: "0 = unlimited" },
        dht_nodes:         { type: "integer" },
        connection_status: { type: "string",  enum: %w[connected firewalled disconnected] },
      }
    },

    "app version" => {
      output: "json",
      record: {
        app_version: { type: "string", note: "e.g. v4.6.3" },
        api_version: { type: "string", note: "e.g. 2.9.3" },
      }
    },

    "app preferences" => {
      output: "json",
      record: "dynamic — introspect live with: qbit app preferences",
      note: "Fields vary by qBittorrent version. Read current prefs to discover shape before writing with 'app set-preferences'.",
    },

    "app set-preferences" => {
      output: "json",
      input: "--json accepts a partial JSON object (only the keys to change)",
      record: { ok: { type: "boolean" } },
      note: "Merged into current preferences server-side. Unknown fields are silently ignored by qBittorrent.",
    },
  }.freeze
end
