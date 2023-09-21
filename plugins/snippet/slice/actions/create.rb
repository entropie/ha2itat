module Ha2itat::Slices
  module Snippet
    module Actions
      class Create < Action

        params do
          required(:ident).filled(:string)
          required(:content).filled(:string)
          optional(:extension).value(:string)
        end


        def handle(req, res)
          params = req.params.to_hash

          if req.post?
            if req.params.valid?
              ext = req.params[:extension].to_sym != :haml ? :markdown : :haml

              adapter = Ha2itat.adapter(:snippet)
              snippet = adapter.create(params[:ident], params[:content], ext)
              res.redirect_to path(:backend_snippet_show, slug: snippet.slug)
            else
              puts req.params.errors
            end

          end
          #res.render(view)
        end
      end
    end
  end
end                      
