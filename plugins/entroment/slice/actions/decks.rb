module Ha2itat::Slices
  module Entroment
    module Actions
      class Decks < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          decks = awu(res) { |adptr| adptr.decks }
          pager = Pager.new(req.params.to_hash, decks)
          decks.each(&:read)

          # if pager.current_items.size == 0 and pager.current_page > 1
          #   res.redirect_to(path(:backend_entroment_decks, page: "last"))
          # end
          pager.link_proc = -> (n) { routes.path(:backend_entroment_decks, page: n) }
          res.render(view, pager: pager)
        end
      end
    end
  end
end
