module Ha2itat::Slices
  module Booking
    module Actions
      class Eventarchive < Action

        def handle(req, res)
          params = req.params.to_hash
          event = booking.events_all.find_or_create(params)

          booking.archive(event)
          res.redirect_to path(:backend_booking_index)
        end
      end
    end
  end
end                      
