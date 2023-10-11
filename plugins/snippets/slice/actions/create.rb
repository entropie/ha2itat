module Ha2itat::Slices
  module Snippets
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

              adapter = Ha2itat.adapter(:snippets)
              snippet = adapter.create(params[:ident], params[:content], ext)
              res.redirect_to path(:backend_snippets_show, slug: snippet.slug)
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
