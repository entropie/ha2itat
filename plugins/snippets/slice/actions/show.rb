module Ha2itat::Slices
  module Snippets
    module Actions
      class Show < Action
        def handle(req, res)
          raise "no id" unless req.params[:slug]
          snippet = adapter(:snippets).select(req.params[:slug])
          res.render(view, snippet: snippet)
        end
      end
    end
  end
end
