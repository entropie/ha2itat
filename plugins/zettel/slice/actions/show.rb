module Ha2itat::Slices
  module Zettel
    module Actions
      class Show < Action

        def handle(req, res)
          sheet = adapter.with_user(session_user(req)).by_id(req.params[:id])
          res.render(view, sheet: sheet)
        end
      end
    end
  end
end
