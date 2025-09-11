module Ha2itat::Slices
  module Tumblogtools
    module Actions
      class API < Action

        def post_to_json(post)
          ret = {  }
          ret[:content] = post.to_html.strip
          ret[:date] = post.created_at.strftime("%Y-%m-%d %H%m")
          ret[:tags] = post.tags
          ret
        end


        def handle(req, res)
          tags = req.params[:fragments]&.split("/")&.grep(/^[\w-]+$/)
          rformat = req.params.raw[:format] || "json"
          raise "nope" if rformat != "json"

          if cfg_api_pw = Ha2itat.C(:api_password)
            if cfg_api_pw != req.params[:password]
              halt 404
            end
          end
          posts = tumblog_posts(req, tags: tags).map{ |pst| post_to_json(pst) }
          
          res.body = posts.to_yaml
        end
      end
    end
  end
end
