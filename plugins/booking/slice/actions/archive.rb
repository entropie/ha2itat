module Ha2itat::Slices
  module Booking
    module Actions
      class Archive < Action

        def handle(req, res)
          events = booking.events_archived
          # res.render(view)
          pager = Pager.new(req.params, events, 2)
          pager.link_proc = -> (n) { routes.path(:backend_booking_archive, page: n) }
          res.render(view, pager: pager, events: events)

        end
      end
    end
  end
end
