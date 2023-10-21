module Ha2itat::Slices
  module Blogtools
    module Actions
      class API < Action

        def handle(req, res)
          limit = Ha2itat.C(:pager_max) || 10
          posts = adapter.posts.sort_by{|p| p.created_at}.reverse.first(limit).map{ |p| p.to_hash }
          res.format = :json
          res.body = posts.to_json
        end
      end
    end
  end
end
