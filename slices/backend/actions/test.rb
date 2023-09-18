require "hanami/action"

module Ha2itat::Slices
  module Backend

    module Actions
      class Test < Action

        def handle(req, res)
          res.render(view)
        end
      end
    end

  end
end
