module Ha2itat::Slices
  module Booking
    module Actions
      class Eventdestroy < Action

        def handle(req, res)
          params = req.params.to_hash
          event = booking.events_all.find_or_create(params)

          # try from archive when not exit
          unless event.exist?
            event = booking.events_archived.select{ |ev| ev.slug == params[:slug] }.shift
          end
          booking.destroy(event)

          res.redirect_to path(:backend_booking_index)
        end
      end
    end
  end
end                      
