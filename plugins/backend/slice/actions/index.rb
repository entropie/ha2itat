require "hanami/action"

module Ha2itat::Slices
  module Backend

    module Actions
      class Index < Action

        def handle(req, res)
          set_meta view, req, title: :backend, image: "foobar", author: "keke"
          res.render(view)
        end
      end
    end

  end
end
