module Ha2itat::Slices
  module Tumblog
    module Actions
      class Show < Action

        params do
          required(:id).filled(:string)
        end

        def handle(req, res)
          if req.params.valid?
            post = adapter.with_user(session_user(req)).by_id(req.params[:id])
            res.render(view, post: post)
          end
        end
      end
    end
  end
end
