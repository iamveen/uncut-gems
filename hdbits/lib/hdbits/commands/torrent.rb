module Hdbits
  module Commands
    SORT_FIELDS = %w[name size added seeders leechers times_completed quality].freeze
    SORT_ORDERS = %w[asc desc].freeze
    QUALITY_VALUES = %w[2160p 1080p 1080i 720p 576p 480p].freeze

    # Higher value = better quality (for desc sort)
    QUALITY_SORT_RANK = {
      "2160p" => 6,
      "1080p" => 5,
      "1080i" => 4,
      "720p"  => 3,
      "576p"  => 2,
      "480p"  => 1,
    }.freeze

    def self.register_torrent(prog)
      prog.desc "Browse and search torrents"
      prog.command :torrent do |t|

        # ── list ──────────────────────────────────────────────────────────────
        t.desc "Search/browse torrents (NDJSON). POST /api/torrents. " \
               "Returns up to --limit results (default 30, max 100). " \
               "Use --raw to get the full API envelope."
        t.command :list do |c|
          add_torrent_search_flags(c)

          c.action do |g, opts, _|
            params = build_torrent_search_params(opts)
            body = g[:client].post("/torrents", params)

            # Client-side quality filtering
            if opts[:quality]
              patterns = parse_quality_patterns(opts[:quality])
              body["data"] = body["data"].select do |t|
                patterns.any? { |pat| t["name"].to_s.include?(pat) }
              end
            end

            # Client-side sorting
            if opts[:sort]
              body["data"] = sort_results(body["data"], opts[:sort], opts[:order])
            end

            Hdbits::Output.emit(body, raw: opts[:raw])
          end
        end

      end
    end

    # ── Shared flags for torrent searching ────────────────────────────────────
    def self.add_torrent_search_flags(c)
      c.flag :id,               desc: "Exact torrent ID lookup",                    type: Integer
      c.flag :hash,             desc: "40-char info-hash"
      c.flag :search,           desc: "Full-text search terms"
      c.flag :category,         desc: "Comma-sep ints: 1=Movie 2=TV 3=Documentary 4=Music 5=Sport 6=AudioTrack 7=XXX 8=Misc"
      c.flag :codec,            desc: "Comma-sep ints: 1=H.264 2=MPEG-2 3=VC-1 4=XviD 5=HEVC"
      c.flag :medium,           desc: "Comma-sep ints: 1=Blu-ray/HD DVD 3=Encode 4=Capture 5=Remux 6=WEB-DL"
      c.flag :origin,           desc: "Comma-sep ints: 0=Undefined 1=Internal"
      c.flag :exclusive,        desc: "Comma-sep ints: 0=Non-exclusive 1=Exclusive"
      c.flag :tags,             desc: "Comma-sep tag IDs (see: hdbits tags)"
      c.flag :quality,          desc: "Comma-sep resolutions (client-side): #{QUALITY_VALUES.join(", ")}"
      c.flag "imdb-id",         desc: "Filter by IMDb numeric ID",                  type: Integer
      c.flag "tvdb-id",         desc: "Filter by TVDB show ID",                     type: Integer
      c.flag "tvdb-season",     desc: "TVDB season number (requires --tvdb-id)",    type: Integer
      c.flag "tvdb-episode",    desc: "TVDB episode number (requires --tvdb-id)",   type: Integer
      c.flag "file-in-torrent", desc: "Filename within the torrent"
      c.switch "snatched-only", desc: "Only torrents this user has snatched",        negatable: false
      c.switch :freeleech,      desc: "Only freeleech torrents",                     negatable: false
      c.switch :internal,       desc: "Only internal releases (origin=1)",           negatable: false
      c.flag :sort,             desc: "Comma-sep sort (client-side): #{SORT_FIELDS.join(", ")}"
      c.flag :order,            desc: "Sort order: asc, desc (default: desc)"
      c.flag :limit,            desc: "Max results, 1–100 (default: 30)",            type: Integer, default_value: 30
      c.flag :page,             desc: "Page offset (default: 0); each page is --limit items", type: Integer, default_value: 0
      c.switch :raw,            desc: "Return full API envelope instead of NDJSON",  negatable: false
    end

    # ── Build params hash from options ────────────────────────────────────────
    def self.build_torrent_search_params(opts, category_override: nil)
      params = {}
      params[:id]             = opts[:id]             if opts[:id]
      params[:hash]           = opts[:hash]           if opts[:hash]
      params[:search]         = opts[:search]         if opts[:search]
      params[:category]       = category_override     if category_override
      params[:category]       = parse_int_list(opts[:category])   if opts[:category] && !category_override
      params[:codec]          = parse_int_list(opts[:codec])      if opts[:codec]
      params[:medium]         = parse_int_list(opts[:medium])     if opts[:medium]
      params[:origin]         = parse_int_list(opts[:origin])     if opts[:origin]
      params[:origin]         = [1]                               if opts[:internal]
      params[:exclusive]      = parse_int_list(opts[:exclusive])  if opts[:exclusive]
      params[:tags]           = parse_int_list(opts[:tags])       if opts[:tags]
      params[:imdb]           = { id: opts["imdb-id"] }           if opts["imdb-id"]
      params[:tvdb]           = build_tvdb(opts)                  if opts["tvdb-id"]
      params[:file_in_torrent] = opts["file-in-torrent"]          if opts["file-in-torrent"]
      params[:snatched_only]   = true                             if opts["snatched-only"]
      params[:freeleech]       = 1                                if opts[:freeleech]
      # sort/order handled client-side
      params[:limit]          = opts[:limit]
      params[:page]           = opts[:page]
      params
    end

    # Parse "1,2,3" → [1, 2, 3]
    def self.parse_int_list(str)
      str.to_s.split(",").map { |s| s.strip.to_i }
    end

    def self.build_tvdb(opts)
      h = { id: opts["tvdb-id"] }
      h[:season]  = opts["tvdb-season"]  if opts["tvdb-season"]
      h[:episode] = opts["tvdb-episode"] if opts["tvdb-episode"]
      h
    end

    # ── Client-side quality filtering ─────────────────────────────────────────
    def self.parse_quality_patterns(str)
      str.to_s.split(",").map do |q|
        q = q.strip.downcase
        unless QUALITY_SORT_RANK.key?(q)
          raise "Unknown quality: #{q}. Use: #{QUALITY_VALUES.join(", ")}"
        end
        q
      end
    end

    # ── Client-side sorting ───────────────────────────────────────────────────
    def self.sort_results(data, sort_str, order)
      fields = sort_str.to_s.split(",").map(&:strip)
      desc = (order.to_s.downcase != "asc")

      data.sort do |a, b|
        cmp = 0
        fields.each do |field|
          cmp = compare_by_field(a, b, field)
          break if cmp != 0
        end
        desc ? -cmp : cmp
      end
    end

    def self.compare_by_field(a, b, field)
      va = sort_value(a, field)
      vb = sort_value(b, field)
      va <=> vb || 0
    end

    def self.sort_value(record, field)
      case field
      when "quality"
        name = record["name"].to_s
        QUALITY_SORT_RANK.each do |res, rank|
          return rank if name.include?(res)
        end
        0  # unknown quality sorts last
      when "seeders", "leechers", "size", "times_completed"
        record[field].to_i
      when "added"
        record["utadded"].to_i
      when "name"
        record["name"].to_s.downcase
      else
        record[field].to_s
      end
    end
  end
end
