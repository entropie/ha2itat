require "hanami/action"

module Ha2itat::Slices
  module Snippets

    module Actions
      class Update < Action

        def handle(req, res)
          res.render(view)
        end
      end
    end

  end
end
