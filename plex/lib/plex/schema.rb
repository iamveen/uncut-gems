module Plex
  SCHEMAS = {
    "server info" => {
      output: "json",
      record: {
        friendlyName:                    { type: "string" },
        version:                         { type: "string" },
        platform:                        { type: "string" },
        machineIdentifier:               { type: "string" },
        myPlexUsername:                  { type: "string" },
        transcoderActiveVideoSessions:   { type: "integer" },
      }
    },
    "server prefs" => {
      output: "ndjson",
      record: {
        id:          { type: "string" },
        label:       { type: "string" },
        summary:     { type: "string" },
        type:        { type: "string" },
        default:     { type: "any" },
        value:       { type: "any" },
        enumValues:  { type: "string", note: "pipe-separated list of allowed values" }
      }
    },
    "server activities" => {
      output: "ndjson",
      record: {
        uuid:        { type: "string" },
        type:        { type: "string" },
        title:       { type: "string" },
        subtitle:    { type: "string" },
        progress:    { type: "integer", note: "0-100" },
        cancellable: { type: "boolean" }
      }
    },
    "server butler" => {
      output: "ndjson",
      record: {
        name:                { type: "string" },
        enabled:             { type: "boolean" },
        lastExecutionTime:   { type: "string", format: "iso8601" },
        nextExecutionTime:   { type: "string", format: "iso8601" }
      }
    },
    "library list" => {
      output: "ndjson",
      record: {
        key:        { type: "integer", note: "section key used in other commands" },
        title:      { type: "string" },
        type:       { type: "string", enum: ["movie", "show", "artist", "photo"] },
        agent:      { type: "string" },
        scanner:    { type: "string" },
        language:   { type: "string" },
        updatedAt:  { type: "integer", format: "unix_seconds" },
        scannedAt:  { type: "integer", format: "unix_seconds" }
      }
    },
    "library browse" => {
      output: "ndjson",
      record: {
        ratingKey:  { type: "string" },
        title:      { type: "string" },
        year:       { type: "integer" },
        type:       { type: "string" },
        viewCount:  { type: "integer" },
        duration:   { type: "integer", format: "milliseconds" },
        addedAt:    { type: "integer", format: "unix_seconds" },
        thumb:      { type: "string" },
        imdb_id:    { type: "string", note: "IMDb ID (tt-prefixed); only present with --include-guids" },
        tmdb_id:    { type: "string", note: "TMDB ID; only present with --include-guids" },
        tvdb_id:    { type: "string", note: "TVDB ID; only present with --include-guids" }
      }
    },
    "metadata get" => {
      output: "json",
      record: {
        ratingKey:               { type: "string" },
        title:                   { type: "string" },
        originalTitle:           { type: "string" },
        summary:                 { type: "string" },
        tagline:                 { type: "string" },
        contentRating:           { type: "string" },
        rating:                  { type: "number" },
        audienceRating:          { type: "number" },
        year:                    { type: "integer" },
        originallyAvailableAt:   { type: "string", format: "date" },
        studio:                  { type: "string" },
        duration:                { type: "integer", format: "milliseconds" },
        thumb:                   { type: "string" },
        art:                     { type: "string" },
        Genre:                   { type: "array", items: { tag: "string" } },
        Director:                { type: "array", items: { tag: "string" } },
        Writer:                  { type: "array", items: { tag: "string" } },
        Role:                    { type: "array", items: { tag: "string", role: "string", thumb: "string" } },
        Media:                   { type: "array", note: "file/stream info" }
      }
    },
    "metadata children" => {
      output: "ndjson",
      record: {
        ratingKey:        { type: "string" },
        title:            { type: "string" },
        index:            { type: "integer", note: "season/episode/track number" },
        viewCount:        { type: "integer" },
        leafCount:        { type: "integer" },
        viewedLeafCount:  { type: "integer" },
        duration:         { type: "integer", format: "milliseconds" },
        thumb:            { type: "string" }
      }
    },
    "search" => {
      output: "ndjson",
      record: {
        ratingKey:  { type: "string" },
        title:      { type: "string" },
        year:       { type: "integer" },
        type:       { type: "string" },
        thumb:      { type: "string" },
        _hub:       { type: "string", note: "synthetic field: hub title this result came from" }
      }
    },
    "sessions list" => {
      output: "ndjson",
      record: {
        ratingKey:    { type: "string" },
        title:        { type: "string" },
        type:         { type: "string" },
        viewOffset:   { type: "integer", format: "milliseconds" },
        sessionKey:   { type: "string" },
        User:         { type: "object", note: "id, title" },
        Player:       { type: "object", note: "title, product, platform, state, machineIdentifier" },
        TranscodeSession: { type: "object", note: "videoDecision, audioDecision, progress" }
      }
    },
    "history" => {
      output: "ndjson",
      record: {
        historyKey:       { type: "string" },
        ratingKey:        { type: "string" },
        title:            { type: "string" },
        grandparentTitle: { type: "string" },
        parentTitle:      { type: "string" },
        type:             { type: "string" },
        accountID:        { type: "integer" },
        deviceID:         { type: "string" },
        duration:         { type: "integer", format: "milliseconds" },
        viewedAt:         { type: "integer", format: "unix_seconds" },
        viewedAtISO:      { type: "string", format: "iso8601" }
      }
    },
    "playlists list" => {
      output: "ndjson",
      record: {
        ratingKey:    { type: "string" },
        title:        { type: "string" },
        playlistType: { type: "string", enum: ["video", "audio", "photo"] },
        smart:        { type: "boolean" },
        duration:     { type: "integer", format: "milliseconds" },
        leafCount:    { type: "integer" },
        updatedAt:    { type: "integer", format: "unix_seconds" }
      }
    },
    "playlists items" => {
      output: "ndjson",
      record: {
        playlistItemID: { type: "string", note: "use this (not ratingKey) for move/remove" },
        ratingKey:      { type: "string" },
        title:          { type: "string" },
        duration:       { type: "integer", format: "milliseconds" },
        type:           { type: "string" }
      }
    },
    "collections list" => {
      output: "ndjson",
      record: {
        ratingKey:     { type: "string" },
        title:         { type: "string" },
        subtype:       { type: "string" },
        childCount:    { type: "integer" },
        contentRating: { type: "string" },
        addedAt:       { type: "integer", format: "unix_seconds" }
      }
    },
    "hubs list" => {
      output: "ndjson",
      record: {
        hubKey:    { type: "string" },
        title:     { type: "string" },
        type:      { type: "string" },
        size:      { type: "integer" },
        items:     { type: "array", note: "each item has ratingKey, title, type, viewOffset" }
      }
    },
    "scrobble" => {
      output: "json",
      record: {
        ok:     { type: "boolean" },
        status: { type: "integer" }
      }
    },
    "dvr list" => {
      output: "ndjson",
      record: {
        key:     { type: "string" },
        title:   { type: "string" },
        type:    { type: "string" },
        product: { type: "string" }
      }
    },
    "accounts list" => {
      output: "ndjson",
      record: {
        id:                      { type: "integer" },
        key:                     { type: "string", note: "e.g. /accounts/1" },
        name:                    { type: "string" },
        defaultAudioLanguage:    { type: "string" },
        autoSelectAudio:         { type: "boolean" },
        defaultSubtitleLanguage: { type: "string" },
        subtitleMode:            { type: "integer" },
        thumb:                   { type: "string", note: "avatar URL" }
      }
    },
    "accounts get" => {
      output: "json",
      record: {
        id:                      { type: "integer" },
        key:                     { type: "string" },
        name:                    { type: "string" },
        defaultAudioLanguage:    { type: "string" },
        autoSelectAudio:         { type: "boolean" },
        defaultSubtitleLanguage: { type: "string" },
        subtitleMode:            { type: "integer" },
        thumb:                   { type: "string" }
      }
    },
    "accounts myplex" => {
      output: "json",
      record: {
        username:             { type: "string" },
        signInState:          { type: "string", enum: ["ok", "unknown"] },
        subscriptionActive:   { type: "boolean" },
        subscriptionState:    { type: "string" },
        subscriptionFeatures: { type: "string", note: "comma-separated feature entitlements" },
        publicAddress:        { type: "string" },
        publicPort:           { type: "string" },
        privateAddress:       { type: "string" },
        privatePort:          { type: "string" },
        mappingState:         { type: "string" },
        mappingError:         { type: "string" }
      }
    },
    "accounts home list" => {
      output: "ndjson",
      record: {
        id:          { type: "string" },
        uuid:        { type: "string" },
        title:       { type: "string" },
        username:    { type: "string" },
        email:       { type: "string" },
        thumb:       { type: "string", note: "avatar URL" },
        hasPassword: { type: "boolean" },
        restricted:  { type: "boolean" },
        admin:       { type: "boolean" },
        guest:       { type: "boolean" }
      }
    },
    "accounts home get" => {
      output: "json",
      record: {
        id:          { type: "string" },
        uuid:        { type: "string" },
        title:       { type: "string" },
        username:    { type: "string" },
        email:       { type: "string" },
        thumb:       { type: "string" },
        hasPassword: { type: "boolean" },
        restricted:  { type: "boolean" },
        admin:       { type: "boolean" },
        guest:       { type: "boolean" }
      }
    }
  }.freeze
end
