module Ha2itat::Slices
  module Zettel
    module Actions
      class References < Action

        include Ha2itat.h(:pager)

        params do
          required(:ref).filled("string")
        end

        def handle(req, res)
          if req.params.valid?
            sheets = adapter.with_user(session_user(req)).by_reference_sorted( req.params[:ref] )
            # pager = Pager.new(req.params.to_hash, sheets)
            # pager.link_proc = -> (n) { routes.path(:backend_zettel_references, slug: req.params[:slug], page: n) }
            res.render(view, sheets: sheets)
          end
        end
      end
    end
  end
end
