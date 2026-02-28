module Ha2itat::Slices
  module Polygram
    module Actions
      class Observe < Action

        def handle(req, res)
          caze = adapter.by_id(req.params[:id])
          cazemedia = caze.media(req.params[:mid])

          observation = adapter.observations_for(caze).select{ |rdng| rdng.user.id == session_user(req).id }.shift rescue nil
          

          if req.post?
            text = req.params[:text]
            observation = adapter.edit_observation(caze, cazemedia.id, session_user(req), text)
            res.redirect_to path(:backend_polygram_show, id: caze.id)
          end

          res.render(view, caze: caze, media: cazemedia, text: observation&.text)
        end
      end
    end
  end
end
