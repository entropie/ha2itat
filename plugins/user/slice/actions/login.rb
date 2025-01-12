module Ha2itat::Slices
  module User
    module Actions
      class Login < Action

        params do
          required(:name).filled(:string)
          required(:password).filled(:string)
        end

        def handle(req, res)
          res.redirect_to(path(:backend_index)) if session_user(req)
          if req.post? and req.params.valid?
            req.env['warden'].authenticate(:password)
            res.redirect_to(path(:backend_index))
          end
        end
      end
    end
  end
end
