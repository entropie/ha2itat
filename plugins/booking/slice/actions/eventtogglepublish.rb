module Ha2itat::Slices
  module Booking
    module Actions
      class Eventtogglepublish < Action

        params do
          required(:slug).filled(:string)
          optional(:goto).value(:string)
        end


        def handle(req, res)
          if req.params.valid?
            event = booking.by_slug(req.params[:slug])            
            if event.published? then event.unpublish! else event.publish! end
            booking.store(event)

            res.redirect_to(redirect_target_from_request(req) || path(:backend_booking_event_show, slug: event.slug))

          end
          # res.redirect_to path(:backend_booking_event_show, slug: event.slug)
        end

      end
    end
  end
end                      
