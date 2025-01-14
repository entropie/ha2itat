module Ha2itat::Slices
  module Entroment
    module Actions
      class Rate < Action

        params do
          required(:rating).filled(:integer)
          required(:cardid).filled(:string)
          required(:name).filled(:string)
          optional(:sessionid).filled(:string)
        end

        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }
          card = deck.cards[req.params[:cardid]]
          rating = req.params[:rating]
          sessionid = req.params[:sessionid]


          halt 500 unless req.params.valid?

          ohash = { name: deck.name, cardid: card.id, rated: rating }

          if session = deck.sessions[sessionid]
            ohash.merge!(sessionid: session.id)
            session.transaction do |sssn|
              scard = sssn.deal!
              sssn.rate(scard, rating.to_i)
            end
            res.redirect_to path(:backend_entroment_session, ohash)
          else
            card.rate(rating.to_i)
            res.redirect_to path(:backend_entroment_card, ohash)
          end

        end

      end
    end
  end
end

