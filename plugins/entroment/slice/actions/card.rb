module Ha2itat::Slices
  module Entroment
    module Actions
      class Card < Action

        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }
          card = deck.cards[req.params[:cardid]]
          rated = req.params[:rated]
          collapsed = req.params[:collapsed].to_i==1 ? true : false
          paramshash = { card: card, deck: deck, collapsed: collapsed, rated: rated }
          paramshash.merge!(sessionid: req.params[:sessionid]) if req.params[:sessionid]
          res.render(view, **paramshash)
        end
      end
    end
  end
end
