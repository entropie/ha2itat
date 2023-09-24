module Ha2itat::Slices
  module Booking
    module Actions
      class Eventshow < Action

        def handle(req, res)
          event = booking.by_slug(req.params[:slug])
          res.render(view, event: event)
        end
      end
    end
  end
end                      
