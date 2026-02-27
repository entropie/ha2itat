module Ha2itat::Slices
  module Polygram
    module Actions
      class Show < Action

        def handle(req, res)
          caze = adapter.by_id(req.params[:id])
          res.render(view, caze: caze, complete: true)
        end
      end
    end
  end
end
