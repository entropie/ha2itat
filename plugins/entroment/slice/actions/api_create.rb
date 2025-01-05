module Ha2itat::Slices
  module Entroment
    module Actions
      class APICreate < Action

        params do
          optional(:tags).filled(:string)
          required(:content).filled(:string)
          required(:token).filled(:string)
        end

        def verify_csrf_token?(*args)
          false
        end

        def handle(req, res)
          res.format = :json
          res.body = [create_or_edit_post(req, res).to_hash].to_json
        end
      end
    end
  end
end
