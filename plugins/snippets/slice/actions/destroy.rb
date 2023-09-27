module Ha2itat::Slices
  module Snippets
    module Actions
      class Destroy < Action

        def handle(req, res)
          snippet = adapter(:snippets).select(req.params[:slug])
          adapter(:snippets).destroy(snippet)
          res.redirect_to(redirect_target_from_request(req) || path(:backend_snippets_index))
        end
      end
    end
  end
end                      
