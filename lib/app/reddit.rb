require "net/http"
require "json"

module Ha2itat
  class RedditClient
    TOKEN_URL = URI("https://www.reddit.com/api/v1/access_token")

    def initialize(client_id:, user_agent:, device_id: "DO_NOT_TRACK_THIS_DEVICE", bearer: nil)
      @client_id = client_id
      @user_agent = user_agent
      @device_id = device_id
      @access_token = bearer
    end

    def get_json(path)
      response = request_json(path)
      Ha2itat.log("RedditClient: requesting json for #{path}")
      
      if response.code.to_i == 401
        @access_token = nil
        response = request_json(path)
      end

      raise "RedditClient: API returned HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
      Ha2itat.log("RedditClient: requesting json success: #{path}")

      JSON.parse(response.body)
    end

    def access_token
      @access_token ||= fetch_token
    end

    private

    def request_json(path)
      uri = URI("https://oauth.reddit.com#{path}")

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{access_token}"
      request["User-Agent"] = @user_agent

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def fetch_token
      request = Net::HTTP::Post.new(TOKEN_URL)
      request.basic_auth(@client_id, "")
      request["User-Agent"] = @user_agent
      request.set_form_data(
        "grant_type" => "https://oauth.reddit.com/grants/installed_client",
        "device_id" => @device_id
      )
      Ha2itat.log("RedditClient: requesting access token")

      response = Net::HTTP.start(TOKEN_URL.host, TOKEN_URL.port, use_ssl: true) do |http|
        http.request(request)
      end

      raise "RedditClient: Failed to obtain token: HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
      Ha2itat.log("RedditClient: token received")

      JSON.parse(response.body).fetch("access_token")
    end
  end
end
