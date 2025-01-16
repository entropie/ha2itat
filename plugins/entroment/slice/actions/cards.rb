module Ha2itat::Slices
  module Entroment
    module Actions
      class Cards < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          entries = awu(res) { |adptr| adptr.entries.sort_by{ |e|e.created_at }.reverse }
          pager = Pager.new(req.params.to_hash, entries)

         if pager.current_items.size == 0 and pager.current_page > 1
           res.redirect_to(path(:backend_entroment_cards, page: "last"))
         end

         pager.link_proc = -> (n) { routes.path(:backend_entroment_cards, page: n) }
                   
         res.render(view, pager: pager)
        end
      end
    end
  end
end
