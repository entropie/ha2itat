module Ha2itat::Slices
  module Galleries
    module Actions
      class Create < Action

        params do
          required(:ident).filled(:string)
        end

        def handle(req, res)
          if req.post?
            if req.params.valid?
              gallery = adapter.find_or_create(req.params[:ident])
              adapter.transaction(gallery)
              res.redirect_to(path(:backend_galleries_show, slug: gallery.ident))
            end
          end
          # res.render(view)
        end
      end
    end
  end
end
