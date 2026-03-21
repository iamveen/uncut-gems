require "faraday"
require "json"

module TMDB
  class Client
    BASE_URL = "https://api.themoviedb.org/3"

    def initialize(api_key:)
      @api_key = api_key
      @conn = Faraday.new(url: BASE_URL) do |f|
        f.headers["Accept"] = "application/json"
        f.request :url_encoded
        f.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    def delete(path, params = {})
      request(:delete, path, params)
    end

    private

    def request(method, path, params)
      # Always include API key in params
      params = params.merge(api_key: @api_key)
      params = params.compact.transform_values(&:to_s)

      res = if %i[get delete].include?(method)
        @conn.send(method, path) { |req| req.params.merge!(params) }
      else
        @conn.send(method, path, params)
      end

      unless res.success?
        $stderr.puts "Error: HTTP #{res.status} #{res.reason_phrase}"
        $stderr.puts res.body unless res.body.to_s.strip.empty?
        exit 1
      end

      ct = res.headers["content-type"].to_s
      if ct.include?("json")
        JSON.parse(res.body)
      elsif res.body.to_s.strip.empty?
        { "ok" => true, "status" => res.status }
      else
        res.body
      end
    end
  end
end
