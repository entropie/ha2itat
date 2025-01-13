module Ha2itat::Slices
  module Entroment
    module Actions
      class Rate < Action

        params do
          required(:rating).filled(:integer)
          required(:cardid).filled(:string)
          required(:name).filled(:string)
        end

        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }
          card = deck.cards[req.params[:cardid]]
          rating = req.params[:rating]
          if req.params.valid?
            card.rate(rating.to_i)
            res.redirect_to path(:backend_entroment_card, name: deck.name, cardid: card.id, rated: rating)
          end
          halt 500
        end
      end
    end
  end
end
