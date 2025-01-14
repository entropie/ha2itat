module Ha2itat::Slices
  module Entroment
    module Actions
      class Sessiondestroy < Action

        params do
          required(:name).filled(:string)
          required(:sessionid).filled(:string)
          optional(:goto).filled(:string)
        end



        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }
          sessionid = req.params[:sessionid]
          session = deck.sessions[sessionid]
          session.destroy
          res.redirect_to(redirect_target_from_request(req) ||
                          path(:backend_entroment_deck, name: deck.name))
        end
      end
    end
  end
end
