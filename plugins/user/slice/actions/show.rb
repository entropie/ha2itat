require "hanami/action"

module Ha2itat::Slices
  module User

    module Actions
      class Show < Action
        
        params { required(:id).filled(:string) }

        handle_exception EntryNotFound => :error_handler

        def handle(req, res)
          usr = adapter(:user).by_id(req.params[:id])

          raise EntryNotFound, "foobar" unless usr

          res.render(view, user: usr)
        end

      end
    end

  end
end
