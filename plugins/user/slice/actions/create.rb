require "hanami/action"

module Ha2itat::Slices
  module User

    module Actions
      class Create < Action

        params do
          required(:email).filled(:string)
          required(:name).filled(:string)
          optional(:groups)
          required(:password).filled(:string)
          required(:password1).filled(:string)
        end

        def handle(req, res)
          if req.post?
            if req.params.valid?
              adapter = Ha2itat.adapter(:user)
              newuser = adapter.create(req.params.to_hash)
              res.redirect_to path(:backend_user_show, user_id: newuser.id)
            else
              puts req.params.errors
            end
          end
        end

      end
    end

  end
end
