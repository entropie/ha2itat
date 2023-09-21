module Ha2itat::Slices
  module Snippet
    module Actions
      class Show < Action
        def handle(req, res)
          raise "no id" unless req.params[:slug]
          snippet = adapter(:snippet).select(req.params[:slug])
          res.render(view, snippet: snippet)
        end
      end
    end
  end
end                      
