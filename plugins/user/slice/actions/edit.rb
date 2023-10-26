module Ha2itat::Slices
  module User
    module Actions
      class Edit < Action

        params do
          required(:user_id).filled(:string)
          required(:email).filled(:string)
          required(:name).filled(:string)
          optional(:groups)
          optional(:password).value(:string)
          optional(:password1).value(:string)
        end

        def enforce_permissions_for(user, req)
          if user != session_user(req).id and not session_user(req).admin?
            halt 503
          end
        end

        def handle(req, res)
          raise "no id" unless req.params[:user_id]
          user = adapter(:user).by_id(req.params[:user_id])


          if req.post? and req.params.valid?
            enforce_permissions_for(user, req)

            new_user_params = req.params.to_hash

            new_name = new_user_params[:name]
            if user.name != new_name
              raise "cannot change name; delete and recreate instead"
            end

            user.populate(new_user_params)

            adapter(:user).store(user)
            res.redirect_to path(:backend_user_edit, user_id: user.id)
          end

          res.render(view, user: user)
        end
      end
    end
  end
end
