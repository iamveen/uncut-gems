module TMDB
  SCHEMAS = {
    "search movie" => {
      output: "ndjson",
      record: {
        id: { type: "integer" },
        title: { type: "string" },
        original_title: { type: "string" },
        overview: { type: "string" },
        release_date: { type: "string", format: "date" },
        poster_path: { type: "string", nullable: true },
        backdrop_path: { type: "string", nullable: true },
        popularity: { type: "number" },
        vote_average: { type: "number" },
        vote_count: { type: "integer" },
        adult: { type: "boolean" },
        video: { type: "boolean" },
        genre_ids: { type: "array", items: { type: "integer" } },
        original_language: { type: "string" }
      }
    },
    "search tv" => {
      output: "ndjson",
      record: {
        id: { type: "integer" },
        name: { type: "string" },
        original_name: { type: "string" },
        overview: { type: "string" },
        first_air_date: { type: "string", format: "date" },
        poster_path: { type: "string", nullable: true },
        backdrop_path: { type: "string", nullable: true },
        popularity: { type: "number" },
        vote_average: { type: "number" },
        vote_count: { type: "integer" },
        genre_ids: { type: "array", items: { type: "integer" } },
        original_language: { type: "string" },
        origin_country: { type: "array", items: { type: "string" } }
      }
    },
    "search person" => {
      output: "ndjson",
      record: {
        id: { type: "integer" },
        name: { type: "string" },
        known_for_department: { type: "string" },
        popularity: { type: "number" },
        profile_path: { type: "string", nullable: true },
        adult: { type: "boolean" },
        known_for: { type: "array", items: { type: "object" } }
      }
    },
    "movie details" => {
      output: "json",
      record: {
        id: { type: "integer" },
        title: { type: "string" },
        original_title: { type: "string" },
        tagline: { type: "string" },
        overview: { type: "string" },
        release_date: { type: "string", format: "date" },
        runtime: { type: "integer", nullable: true },
        budget: { type: "integer" },
        revenue: { type: "integer" },
        status: { type: "string" },
        poster_path: { type: "string", nullable: true },
        backdrop_path: { type: "string", nullable: true },
        imdb_id: { type: "string", nullable: true },
        homepage: { type: "string", nullable: true },
        popularity: { type: "number" },
        vote_average: { type: "number" },
        vote_count: { type: "integer" },
        adult: { type: "boolean" },
        video: { type: "boolean" },
        genres: { type: "array", items: { type: "object" } },
        production_companies: { type: "array", items: { type: "object" } },
        production_countries: { type: "array", items: { type: "object" } },
        spoken_languages: { type: "array", items: { type: "object" } }
      }
    },
    "tv details" => {
      output: "json",
      record: {
        id: { type: "integer" },
        name: { type: "string" },
        original_name: { type: "string" },
        tagline: { type: "string" },
        overview: { type: "string" },
        first_air_date: { type: "string", format: "date" },
        last_air_date: { type: "string", format: "date" },
        status: { type: "string" },
        type: { type: "string" },
        number_of_seasons: { type: "integer" },
        number_of_episodes: { type: "integer" },
        episode_run_time: { type: "array", items: { type: "integer" } },
        poster_path: { type: "string", nullable: true },
        backdrop_path: { type: "string", nullable: true },
        homepage: { type: "string", nullable: true },
        popularity: { type: "number" },
        vote_average: { type: "number" },
        vote_count: { type: "integer" },
        genres: { type: "array", items: { type: "object" } },
        networks: { type: "array", items: { type: "object" } },
        production_companies: { type: "array", items: { type: "object" } },
        seasons: { type: "array", items: { type: "object" } }
      }
    },
    "person details" => {
      output: "json",
      record: {
        id: { type: "integer" },
        name: { type: "string" },
        biography: { type: "string" },
        birthday: { type: "string", format: "date", nullable: true },
        deathday: { type: "string", format: "date", nullable: true },
        place_of_birth: { type: "string", nullable: true },
        known_for_department: { type: "string" },
        popularity: { type: "number" },
        profile_path: { type: "string", nullable: true },
        adult: { type: "boolean" },
        imdb_id: { type: "string", nullable: true },
        homepage: { type: "string", nullable: true },
        also_known_as: { type: "array", items: { type: "string" } }
      }
    },
    "discover movie" => {
      output: "ndjson",
      record: {
        id: { type: "integer" },
        title: { type: "string" },
        original_title: { type: "string" },
        overview: { type: "string" },
        release_date: { type: "string", format: "date" },
        poster_path: { type: "string", nullable: true },
        backdrop_path: { type: "string", nullable: true },
        popularity: { type: "number" },
        vote_average: { type: "number" },
        vote_count: { type: "integer" },
        adult: { type: "boolean" },
        genre_ids: { type: "array", items: { type: "integer" } }
      }
    },
    "discover tv" => {
      output: "ndjson",
      record: {
        id: { type: "integer" },
        name: { type: "string" },
        original_name: { type: "string" },
        overview: { type: "string" },
        first_air_date: { type: "string", format: "date" },
        poster_path: { type: "string", nullable: true },
        backdrop_path: { type: "string", nullable: true },
        popularity: { type: "number" },
        vote_average: { type: "number" },
        vote_count: { type: "integer" },
        genre_ids: { type: "array", items: { type: "integer" } }
      }
    },
    "trending" => {
      output: "ndjson",
      record: {
        id: { type: "integer" },
        media_type: { type: "string", enum: ["movie", "tv", "person"] },
        title: { type: "string", description: "For movies" },
        name: { type: "string", description: "For TV shows and people" },
        overview: { type: "string" },
        popularity: { type: "number" },
        vote_average: { type: "number" },
        poster_path: { type: "string", nullable: true },
        backdrop_path: { type: "string", nullable: true }
      }
    }
  }.freeze

  def self.schema_for(command_name)
    SCHEMAS[command_name]
  end
end
