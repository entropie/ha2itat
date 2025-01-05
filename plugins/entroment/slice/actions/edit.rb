module Ha2itat::Slices
  module Entroment
    module Actions
      class Edit < Action

        params do
          optional(:id).filled(:string)
          optional(:tags).filled(:string)
          optional(:content).filled(:string)
        end

        def handle(req, res)
          entry = awu(req){|adptr| adptr.by_id(req.params[:id]) }
          if req.post?
            entry = create_or_edit_post(req, res)
          end

          res.render(view, entry: entry)
        end
      end
    end
  end
end
