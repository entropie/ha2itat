module Ha2itat::Slices
  module Booking
    module Actions
      class Eventedit < Action

        def handle(req, res)
          event = booking.by_slug(req.params[:slug])

          if req.post?
            booking.update(event, req.params.to_hash)
          end
          res.render(view, event: event)
        end
      end
    end
  end
end                      
