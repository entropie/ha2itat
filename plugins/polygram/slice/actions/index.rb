module Ha2itat::Slices
  module Polygram
    module Actions
      class Index < Action

        def handle(req, res)
          res.render(view, cases: adapter.cases)
        end
      end
    end
  end
end
