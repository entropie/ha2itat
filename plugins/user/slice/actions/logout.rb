require "hanami/action"

module Ha2itat::Slices
  module User

    module Actions
      class Logout < Action

        def handle(req, res)
          req.env["warden"].logout rescue nil
          res.redirect_to(routes.path(:index))
        end

      end
    end

  end
end
