module Ha2itat::Slices
  module Snippet
    module Actions
      class Edit < Action

        params do
          required(:slug).filled(:string)
          required(:content).filled(:string)
        end

        def handle(req, res)
          raise "no id" unless req.params[:slug]
          snippet = adapter(:snippet).select(req.params[:slug])

          if req.post? and req.params.valid?
            adapter(:snippet).store(snippet, req.params[:content])

            res.redirect_to path(:backend_snippet_edit, slug: snippet.slug)
          end


          
          res.render(view, snippet: snippet)
        end
      end
    end
  end
end                      
