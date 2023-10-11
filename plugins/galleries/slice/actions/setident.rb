module Ha2itat::Slices
  module Galleries
    module Actions
      class Setident < Action


        params do
          required(:slug).filled(:string)
          required(:ident).filled(:string)
          required(:hash).filled(:string)
          optional(:goto)
        end

        def handle(req, res)
          if req.params.valid?
            gallery = adapter.find_or_create(req.params[:slug])

            img = gallery.images(req.params[:hash])

            adapter.transaction(gallery) do |g|
              g.set_ident(img, req.params[:ident])
            end
            res.redirect_to(redirect_target_from_request(req) || path(:backend_galleries_show, slug: gallery.ident))
          end

        end
      end
    end
  end
end
