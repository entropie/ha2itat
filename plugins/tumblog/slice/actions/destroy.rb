module Ha2itat::Slices
  module Tumblog
    module Actions
      class Destroy < Action

        def handle(req, res)
          adptr = adapter.with_user(session_user(req))
          post = adptr.by_id(req.params[:id])
          if post
            adptr.destroy(post)
            if req.xhr?
              res.format = :json
              return res.body = { ok: true, deleted: post.id }.to_json
            end
            res.redirect_to(redirect_target_from_request(req) || path(:backend_tumblog_index))
          end
        end
      end
    end
  end
end
