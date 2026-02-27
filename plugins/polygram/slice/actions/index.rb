module Ha2itat::Slices
  module Polygram
    module Actions
      class Index < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          pager = Pager.new(req.params.to_hash, adapter.cases)
          pager.link_proc = -> (n) { routes.path(:backend_polygram_index, page: n ) }
          res.render(view, pager: pager)
        end
      end
    end
  end
end
