module Hdbits
  SCHEMAS = {
    "test" => {
      output: "json",
      record: {
        status:  { type: "integer", note: "0 = success" },
        message: { type: "string",  note: "present on failure" },
      }
    },
    "user" => {
      output: "json",
      record: {
        id:         { type: "integer" },
        added:      { type: "string",  format: "iso8601" },
        uploaded:   { type: "integer", format: "bytes" },
        downloaded: { type: "integer", format: "bytes" },
        bonus:      { type: "number" },
      }
    },
    "tags" => {
      output: "ndjson",
      record: {
        id:   { type: "integer" },
        name: { type: "string" },
      }
    },
    "wishlist list" => {
      output: "ndjson",
      record: {
        id:            { type: "integer" },
        name:          { type: "string" },
        imdb:          { type: "string",  note: "IMDb ID, e.g. tt0133093" },
        added:         { type: "string",  format: "iso8601" },
        originaltitle: { type: "string" },
        englishtitle:  { type: "string" },
        year:          { type: "integer" },
        torrent:       { type: "boolean", note: "true if a matching torrent exists" },
        torrent_id:    { type: "integer", note: "torrent ID if torrent == true, else null" },
      }
    },
    "torrent list" => {
      output: "ndjson",
      note:   "Use --raw to get the full {status, data:[...]} envelope. " \
              "Sort with --sort (name|size|added|seeders|leechers|times_completed|quality) and --order (asc|desc).",
      record: {
        id:               { type: "integer" },
        hash:             { type: "string",  note: "40-char info-hash" },
        name:             { type: "string" },
        descr:            { type: "string" },
        size:             { type: "integer", format: "bytes" },
        seeders:          { type: "integer" },
        leechers:         { type: "integer" },
        times_completed:  { type: "integer" },
        utadded:          { type: "integer", format: "unix-timestamp" },
        added:            { type: "string",  format: "iso8601" },
        comments:         { type: "integer" },
        numfiles:         { type: "integer" },
        filename:         { type: "string",  note: "torrent filename for download" },
        freeleech:        { type: "integer", note: "0=normal, 1=freeleech" },
        type_category:    { type: "integer", enum: [1, 2, 3, 4, 5, 6, 7, 8],
                            note: "1=Movie 2=TV 3=Documentary 4=Music 5=Sport 6=AudioTrack 7=XXX 8=Misc" },
        type_codec:       { type: "integer", enum: [1, 2, 3, 4, 5],
                            note: "1=H.264 2=MPEG-2 3=VC-1 4=XviD 5=HEVC" },
        type_medium:      { type: "integer", enum: [1, 3, 4, 5, 6],
                            note: "1=Blu-ray/HD DVD 3=Encode 4=Capture 5=Remux 6=WEB-DL" },
        type_origin:      { type: "integer", enum: [0, 1],
                            note: "0=Undefined 1=Internal" },
        type_exclusive:   { type: "integer", enum: [0, 1],
                            note: "0=Non-exclusive 1=Exclusive" },
        torrent_status:   { type: "integer" },
        bookmarked:       { type: "boolean" },
        wishlisted:       { type: "boolean" },
        tags:             { type: "array",   items: "string (tag names)" },
        imdb:             { type: "object",  note: "{id, title, ...} — optional" },
        tvdb:             { type: "object",  note: "{id, season, episode, ...} — optional" },
      }
    },
    "top films" => {
      output: "ndjson",
      record: {
        imdb_id: { type: "string",  note: "IMDb ID, e.g. tt0133093" },
        name:    { type: "object",  note: "{original: string, english: string}" },
        amount:  { type: "integer", note: "number of torrents uploaded in the period" },
      }
    },
    "top tv" => {
      output: "ndjson",
      record: {
        id:     { type: "integer", note: "TVDB show ID" },
        name:   { type: "string" },
        amount: { type: "integer", note: "number of torrents uploaded in the period" },
      }
    },
    "subtitles" => {
      output: "ndjson",
      note:   "Download at https://hdbits.org/getdox.php?id=<id>&passkey=<passkey>",
      record: {
        id:         { type: "integer" },
        added:      { type: "string",  format: "iso8601" },
        title:      { type: "string" },
        filename:   { type: "string" },
        language:   { type: "string" },
        torrent_id: { type: "integer" },
      }
    },
  }.freeze
end
