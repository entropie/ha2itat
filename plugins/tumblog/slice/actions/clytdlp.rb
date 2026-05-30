module Ha2itat::Slices
  module Tumblog
    module Actions
      class Clytdlp < Action

        def handle(req, res)
          params = req.params.to_hash
          content, tags = params[:content], params[:tags]

          reddit_path = URI(content).path.sub(%r{/$}, "") + ".json"

          media_url = get_media_url_for(reddit_path)

          res.render(view, content: content, tags: tags, media_url: media_url)
        end

        def get_media_url_for(path)
          reddit = Ha2itat::RedditClient.new(client_id: Ha2itat.C(:reddit_client), user_agent: "wecoso.de")
          json = reddit.get_json(path)
          post = json[0]["data"]["children"][0]["data"]
          post.dig("media", "reddit_video", "fallback_url")
        end
      end
    end
  end
end
