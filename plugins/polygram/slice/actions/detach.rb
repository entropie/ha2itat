module Ha2itat::Slices
  module Polygram
    module Actions
      class Detach < Action

        params do
          required(:id).filled(:string)
          required(:mid).filled(:string)
        end

        def handle(req, res)
          halt 422 unless req.params.valid?

          caze = adapter.by_id(req.params[:id])
          halt 500 unless caze

          adapter.transaction_with(caze) do |adptr|
            adptr.remove_attachment(caze, req.params[:mid])
          end

          res.render(view, caze: caze.id)
        end

      end
    end
  end
end
