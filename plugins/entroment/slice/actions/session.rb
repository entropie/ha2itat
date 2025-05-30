module Ha2itat::Slices
  module Entroment
    module Actions
      class Session < Action

        params do
          required(:name).filled(:string)

          optional(:cardid).filled(:string)
          optional(:length).filled(:integer)
          optional(:sessionid).filled(:string)
          optional(:rated).filled(:string)
          optional(:lastcardid).filled(:string)
        end

        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }

          sessionid = req.params[:sessionid]
          session = nil
          lastcardid = req.params[:lastcardid]
          rated = req.params[:rated]

          if not sessionid
            sopts = req.params[:length] ? { length: req.params[:length] } : { }
            if deck.cards.empty?
              raise "no cards in deck"
            end

            session = deck.new_session(**sopts)
            sessionid = session.id
            res.redirect_to(path(:backend_entroment_session, sessionid: sessionid, name: req.params[:name]))
          else

            deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }
            s = deck.sessions[req.params[:sessionid]]

            if not s.due_left? and not lastcardid
              res.redirect_to( path(:backend_entroment_session_end, name: req.params[:name], sessionid: sessionid))
            end

            card = s.cards.first
            cardid = card.id rescue nil

            res.render(view, sessionid: s.id, name: req.params[:name], cardid: cardid, deck: deck, card: card, s: s, lastcardid: lastcardid, rated: rated)
          end

        end
      end
    end
  end
end
