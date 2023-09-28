module Ha2itat::Slices
  module Galleries
    module Actions
      class Index < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          galleries = adapter.all
          pager = Pager.new(req.params.to_hash, galleries)
          pager.link_proc = -> (n) { routes.path(:backend_galleries_index, page: n ) }
          res.render(view, pager: pager)
        end
      end
    end
  end
end                      
