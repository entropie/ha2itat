module Ha2itat::Slices
  module Tumblogtools
    module Actions
      class API < Action

        def handle(req, res)
          tags = req.params[:fragments]&.split("/")&.grep(/^[\w-_]+$/)

          limit = Ha2itat.C(:pager_max) || 10
          posts = adapter.posts.sort_by{|p| p.created_at}.reverse.first(limit).map{ |p| p.to_hash }
          res.format = :json
          res.body = posts.to_json
        end
      end
    end
  end
end
