module Ha2itat::Slices
  module Entroment
    module Actions
      class Sessionend < Action

        include Ha2itat.h(:pager)

        params do
          required(:name).filled(:string)
          required(:sessionid).filled(:string)
          optional(:page).filled(:string)
        end

        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }
          sessionid = req.params[:sessionid]
          session = deck.sessions[sessionid]
          report = session.report
          pager = Pager.new(req.params.to_hash, report)
          pager.link_proc = -> (n) { routes.path(:backend_entroment_session_end, name: req.params[:name], sessionid: sessionid, page: n) }
          res.render(view, pager: pager, deck: deck, s: session)
        end
      end
    end
  end
end
