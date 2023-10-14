module Ha2itat::Slices
  module Galleries
    module Actions
      class Show < Action
        include Ha2itat.h(:Pager)

        params do
          required(:slug).filled(:string)
          optional(:page)
        end

        def handle(req, res)
          if req.params.valid?
            gallery = adapter.find_or_create(req.params[:slug])

            pager = Pager.new(req.params.to_hash, gallery.images||[])
            pager.link_proc = -> (n) { routes.path(:backend_galleries_show, slug: gallery.ident, page: n ) }


            res.render(view, gallery: gallery, pager: pager)
          end
        end
      end
    end
  end
end
