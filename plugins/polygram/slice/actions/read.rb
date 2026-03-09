module Ha2itat::Slices
  module Polygram
    module Actions
      class Read < Action

        params do
          required(:id).filled(:string)
          required(:mid).filled(:string)
          optional(:text).filled(:string)
        end

        def handle(req, res)
          halt 503 unless req.params.valid?

          caze = adapter.by_id(req.params[:id])
          cazemedia = caze.media(req.params[:mid])

          observation = observation_for(caze, session_user(req), cazemedia.id)
          reading = reading_for(caze, session_user(req), cazemedia.id)
          text = reading&.text

          if req.post?

            errors = {  }
            text = req.params[:text]
            reading = adapter.edit_reading(caze, cazemedia.id, session_user(req), text)

            if observation.markers.size != reading.markers.size
              errors[:markers_size] = "count of timestamps is different for observation and reading; this is not intended"
            end
            if observation.markers.keys != reading.markers.keys
              errors[:markers_keys] = "count of timestamps match but indexes are different; this is not intended"
            end


            # res.redirect_to path(:backend_polygram_show, id: caze.id)
          end

          res.render(view, caze: caze, media: cazemedia, text: text || observation.reading_template, reading: reading, observation: observation, errors: errors)
        end
      end
    end
  end
end
