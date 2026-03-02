module Ha2itat::Slices
  module Polygram
    module Actions
      class Observe < Action

        def handle(req, res)
          caze = adapter.by_id(req.params[:id])
          cazemedia = caze.media(req.params[:mid])

          observations = adapter.observations_for(caze).select{ |rdng| rdng.user.id == session_user(req).id }
          observations.reject!{ |obs| obs.mid != cazemedia.mid }
          raise "this should not happen; multiple observation candidates available" if observations.size > 1
          observation = observations.shift
          

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
