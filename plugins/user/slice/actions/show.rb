require "hanami/action"

module Ha2itat::Slices
  module User

    module Actions
      class Show < Action
        
        params { required(:id).filled(:string) }

        def handle(req, res)
          res.render(view, user: Ha2itat.adapter(:user).by_id(req.params[:id]))
        end

      end
    end

  end
end
