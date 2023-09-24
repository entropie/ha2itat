module Ha2itat::Slices
  module Booking
    module Actions
      class Eventtogglepublish < Action

        def handle(req, res)
          event = booking.by_slug(req.params[:slug])

          if event.published? then event.unpublish! else event.publish! end
          booking.store(event)

          res.redirect_to path(:backend_booking_event_show, slug: event.slug)
        end
      end
    end
  end
end                      
