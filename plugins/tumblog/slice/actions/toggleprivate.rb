module Ha2itat::Slices
  module Tumblog
    module Actions
      class Toggleprivate < Action

        def handle(req, res)
          adptr = adapter.with_user(session_user(req))
          post = adptr.by_id(req.params[:id])
          if post
            post.private = post.private? ? 0 : 1
            adptr.store(post)
            res.redirect_to(redirect_target_from_request(req) || path(:backend_tumblog_index))
          end
        end
      end
    end
  end
end
