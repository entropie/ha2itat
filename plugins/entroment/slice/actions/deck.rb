module Ha2itat::Slices
  module Entroment
    module Actions
      class Deck < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }

          cards = deck.cards
          pager = Pager.new(req.params.to_hash, cards)

          pager.link_proc = -> (n) { routes.path(:backend_entroment_deck, name: req.params[:name], page: n) }

          res.render(view, deck: deck, pager: pager)
        end
      end
    end
  end
end
