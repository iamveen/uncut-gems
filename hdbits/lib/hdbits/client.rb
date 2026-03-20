require "faraday"
require "json"

module Hdbits
  class Client
    BASE_URL = "https://hdbits.org/api/"

    def initialize(username:, passkey:, logger:)
      @username = username
      @passkey  = passkey
      @logger   = logger
      @conn     = Faraday.new(url: BASE_URL, ssl: { verify: true }) do |f|
        f.headers["Content-Type"] = "application/json"
        f.headers["Accept"]       = "application/json"
        f.adapter Faraday.default_adapter
      end
    end

    # POST to /api/<path> with auth injected into the body.
    def post(path, body = {})
      payload = { "username" => @username, "passkey" => @passkey }.merge(stringify_keys(body))

      redacted = payload.merge("passkey" => "[REDACTED]")
      clean_path = path.to_s.sub(%r{\A/+}, "")
      @logger.debug("POST #{BASE_URL}#{clean_path}")
      @conn.headers.each { |k, v| @logger.debug("Request header: #{k}: #{v}") }
      @logger.debug("Request body: #{JSON.generate(redacted)}")

      res = @conn.post(clean_path) do |req|
        req.body = JSON.generate(payload)
      end

      @logger.debug("Response HTTP #{res.status}")
      res.headers.each { |k, v| @logger.debug("Response header: #{k}: #{v}") }
      @logger.debug("Response body: #{res.body}")

      unless res.success?
        @logger.error("HTTP #{res.status}")
        @logger.error(res.body) unless res.body.to_s.strip.empty?
        exit 1
      end

      raw = res.body.to_s.strip
      if raw.empty?
        @logger.error("empty response from server")
        exit 1
      end

      data = JSON.parse(raw)

      unless data.is_a?(Hash) && data["status"] == 0
        status  = data["status"]  rescue "?"
        message = data["message"] rescue raw
        @logger.error("API status #{status}: #{message}")
        exit 1
      end

      data
    end

    private

    def stringify_keys(hash)
      return hash unless hash.is_a?(Hash)
      hash.transform_keys(&:to_s)
    end
  end
end
