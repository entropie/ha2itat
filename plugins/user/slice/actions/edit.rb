module Ha2itat::Slices
  module User
    module Actions
      class Edit < Action

        params do
          required(:id).filled(:string)
          required(:email).filled(:string)
          required(:name).filled(:string)
          optional(:password).value(:string)
          optional(:password1).value(:string)
        end

        def handle(req, res)
          raise "no id" unless req.params[:id]
          user = adapter(:user).by_id(req.params[:id])

          if req.post? and req.params.valid?
            new_user_params = req.params.to_hash
            new_user_params.delete(:id)

            new_name = new_user_params.delete(:name)
            if user.name != new_name 
              raise "cannot change name; delete and recreate instead"
            end
            user.update(new_user_params)
            adapter(:user).store(user)

          end

          res.render(view, user: user)

        end
      end
    end
  end
end                      
