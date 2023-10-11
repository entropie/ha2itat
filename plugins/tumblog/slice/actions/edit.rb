module Ha2itat::Slices
  module Tumblog
    module Actions
      class Edit < Action

        params do
          required(:id).filled(:string)
          optional(:title).value(:string)
          optional(:tags).value(:string)
          required(:content).value(:string)
        end

        def handle(req, res)
          adptr = adapter.with_user(session_user(req))
          post = adptr.by_id(req.params[:id])

          if req.post?
            needs_processing = post.update(req.params.to_hash)
            post.handler.process! if needs_processing
            adptr.update(post)
          end
          res.render(view, post: post)
        end
      end
    end
  end
end
