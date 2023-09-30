module Ha2itat::Slices
  module Galleries
    module Actions
      class Remove < Action

        params do
          required(:slug).filled(:string)
          required(:hash).filled(:string)
        end

        def handle(req, res)
          if req.params.valid?
            gallery = adapter.find_or_create(req.params[:slug])
            adapter.transaction(gallery) do |g|
              g.remove(req.params[:hash])
            end
            res.redirect_to(redirect_target_from_request(req) || path(:backend_galleries_show, slug: gallery.ident))
          end
        end
      end
    end
  end
end                      
