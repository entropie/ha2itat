require "hanami/action"

module Ha2itat::Slices
  module TestSlice

    module Actions
      class TestAction < Hanami::Action

        def handle(req, res)
          res.render(view)
        end
      end
    end

  end
end
