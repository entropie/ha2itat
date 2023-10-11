module Ha2itat::Slices
  module Zettel
    module Actions
      class Destroy < Action

        def handle(req, res)
          sheet = adapter.with_user(session_user(req)).by_id(req.params[:id])
          adapter.destroy(sheet)
          res.redirect_to(redirect_target_from_request(req) || path(:backend_zettel_index))

          # res.render(view)
        end
      end
    end
  end
end
