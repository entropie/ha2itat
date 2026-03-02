module Ha2itat::Slices
  module Polygram
    module Actions
      class Attach < Action

        params do
          required(:id).filled(:string)
          optional(:file).filled(:array)
        end

        def handle(req, res)
          halt 422 unless req.params.valid?

          caze = adapter.by_id(req.params[:id])
          halt 500 unless caze

          adapter.transaction_with(caze) do |adptr|
            (req.params[:file] || []).each do |userfile|
              adptr.upload_for(caze, path: userfile[:tempfile].path)
            end
          end

          res.render(view, caze: caze)
        end

      end
    end
  end
end
