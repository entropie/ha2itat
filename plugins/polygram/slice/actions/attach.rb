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

          if req.post?

            adapter.transaction_with(caze) do |adptr|
              (req.params[:file] || []).each do |userfile|
                adptr.upload_for(caze, path: userfile[:tempfile].path)
              end
              res.redirect_to path(:backend_polygram_show, id: caze.id)
            end
          end

          res.render(view, caze: caze)
        end

      end
    end
  end
end
