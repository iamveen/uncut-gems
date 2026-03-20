# frozen_string_literal: true

require "faraday"
require "faraday/multipart"
require "json"
require "fileutils"

module Qbit
  class Client
    SESSION_FILE = File.expand_path("~/.cache/qbit/session")
    BASE_PATH    = "/api/v2"

    # url      — qBittorrent server root, e.g. "http://localhost:8080"
    # username — qBittorrent username (default: admin)
    # password — qBittorrent password (default: adminadmin)
    def initialize(url:, username:, password:)
      @url      = url.sub(%r{/+$}, "")
      @username = username
      @password = password
      @sid      = load_session
    end

    def get(path, params = {})
      with_reauth { |c| c.get(api(path), compact(params)) }
    end

    def post(path, body = {})
      with_reauth do |c|
        c.post(api(path)) { |r| r.body = compact(body) }
      end
    end

    # POST with a multipart body for .torrent file upload.
    def post_file(path, file_path, params = {})
      resp = do_multipart(path, file_path, params)
      if resp.status == 403
        login!
        resp = do_multipart(path, file_path, params)
      end
      handle(resp)
    end

    def logout!
      body = post("/auth/logout")
      File.delete(SESSION_FILE) if File.exist?(SESSION_FILE)
      @sid = nil
      body
    end

    private

    # ---------------------------------------------------------------------------
    # Request helpers
    # ---------------------------------------------------------------------------

    def with_reauth
      # Ensure we have a session before the first real request.
      login! unless @sid

      resp = yield plain_conn
      if resp.status == 403
        login!
        resp = yield plain_conn
      end
      handle(resp)
    end

    def plain_conn
      sid = @sid
      Faraday.new(url: @url) do |f|
        f.headers["Cookie"] = "SID=#{sid}" if sid
        f.request  :url_encoded
        f.adapter  Faraday.default_adapter
      end
    end

    def do_multipart(path, file_path, params)
      sid = @sid
      conn = Faraday.new(url: @url) do |f|
        f.headers["Cookie"] = "SID=#{sid}" if sid
        f.request  :multipart
        f.request  :url_encoded
        f.adapter  Faraday.default_adapter
      end
      payload = compact(params).merge(
        torrents: Faraday::Multipart::FilePart.new(
          File.open(file_path, "rb"),
          "application/x-bittorrent",
          File.basename(file_path)
        )
      )
      conn.post(api(path), payload)
    end

    # ---------------------------------------------------------------------------
    # Auth / session
    # ---------------------------------------------------------------------------

    def login!
      c = Faraday.new(url: @url) do |f|
        f.request :url_encoded
        f.adapter Faraday.default_adapter
      end
      r = c.post(api("/auth/login"), username: @username, password: @password)

      if r.status == 200 && r.body.strip == "Ok."
        m = r.headers["set-cookie"]&.match(/SID=([^;]+)/)
        abort "Login succeeded but no SID cookie in response" unless m
        @sid = m[1]
        save_session(@sid)
      else
        abort "Login failed (HTTP #{r.status}): #{r.body.strip}"
      end
    end

    def load_session
      File.read(SESSION_FILE).strip if File.exist?(SESSION_FILE)
    rescue
      nil
    end

    def save_session(sid)
      FileUtils.mkdir_p(File.dirname(SESSION_FILE))
      File.write(SESSION_FILE, sid)
    end

    # ---------------------------------------------------------------------------
    # Response handling
    # ---------------------------------------------------------------------------

    def handle(response)
      unless (200..299).cover?(response.status)
        $stderr.puts "Error: HTTP #{response.status}"
        $stderr.puts response.body unless response.body.to_s.strip.empty?
        exit 1
      end

      body = response.body.to_s.strip
      return { "ok" => true, "status" => response.status } if body.empty?

      ct = response.headers["content-type"].to_s
      if ct.include?("json")
        JSON.parse(body)
      elsif body == "Ok."
        { "ok" => true }
      else
        { "ok" => true, "body" => body }
      end
    end

    def api(path)
      "#{BASE_PATH}#{path}"
    end

    def compact(hash)
      return hash unless hash.is_a?(Hash)
      hash.reject { |_, v| v.nil? }
    end
  end
end
