module Ha2itat::Slices
  module Booking
    module Actions
      class Index < Action

        def handle(req, res)
          events = booking.
                     events_all.
                     sort_by{ |ev| ev.start_date }

          pager = Pager.new(req.params, events, 2)
          pager.link_proc = -> (n) { routes.path(:backend_booking_index, page: n) }
          res.render(view, pager: pager, events: events)
        end
      end
    end
  end
end
