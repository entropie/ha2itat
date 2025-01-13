module Ha2itat::Slices
  module Entroment
    module Actions
      class Rate < Action

        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }
          card = deck.cards[req.params[:cardid]]
          rating = req.params[:rating]
          collapsed = rating ? false : req.params[:collapsed]
          card.rate(rating.to_i)

          res.redirect_to path(:backend_entroment_card, name: deck.name, cardid: card.id, rated: rating)

          #res.render(view, card: card, deck: deck, collapsed: collapsed)
        end
      end
    end
  end
end
