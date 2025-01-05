module Ha2itat::Slices
  module Entroment
    module Actions
      class Create < Action

        params do
          required(:tags).filled(:string)
          required(:content).filled(:string)
        end

        def handle(req, res)
          create_or_edit_post(req, res)
        end
      end
    end
  end
end
