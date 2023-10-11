require "hanami/action"

module Ha2itat::Slices
  module User

    module Actions
      class Show < Action

        params { required(:user_id).filled(:string) }

        handle_exception EntryNotFound => :error_handler

        def handle(req, res)
          usr = adapter(:user).by_id(req.params[:user_id])
          raise EntryNotFound, "no user" unless usr
          res.render(view, user: usr)
        end

      end
    end

  end
end
