module Ha2itat::Slices
  module Zettel
    module Actions
      class Index < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          sheets = adapter.with_user(session_user(req)) {|d| d.ordered }
          pager = Pager.new(req.params.to_hash, sheets)
          pager.link_proc = -> (n) { routes.path(:backend_zettel_index, page: n) }
          res.render(view, pager: pager)
        end
      end
    end
  end
end                      
