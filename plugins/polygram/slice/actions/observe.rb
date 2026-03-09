module Ha2itat::Slices
  module Polygram
    module Actions
      class Observe < Action

        def handle(req, res)
          caze = adapter.by_id(req.params[:id])
          cazemedia = caze.media(req.params[:mid])

          observation = observation_for(caze, session_user(req), cazemedia.id)

          if req.post?
            text = req.params[:text]
            observation = adapter.edit_observation(caze, cazemedia.id, session_user(req), text)
            #res.redirect_to path(:backend_polygram_show, id: caze.id, activeMedia: cazemedia.id)
          end

          res.render(view, caze: caze, media: cazemedia, text: observation&.text, observation: observation)
        end
      end
    end
  end
end
