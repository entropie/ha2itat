module Ha2itat::Slices
  module Polygram
    module Actions
      class Show < Action

        params do
          optional(:id).filled(:string)
        end

        def handle(req, res)
          halt 422 unless req.params.valid?

          caze = adapter.by_id(req.params[:id])
          halt 500 unless caze
          res.render(view, caze: caze, complete: false, menu: true)
        end
      end
    end
  end
end
