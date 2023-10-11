module Ha2itat::Slices
  module Booking
    module Actions
      class Create < Action

        # params do
        #   required(:ident).filled(:string)
        #   required(:content).filled(:string)
        #   optional(:extension).value(:string)
        # end

        def handle(req, res)
          event = Plugins::Booking::Events::Event.new
          params = req.params.to_hash


          # pp req.params[:image]
          ##p req.params[:file].read

          #res.render(view, event: event, action: path(:backend_booking_create))
          # pp params

          # req["CONTENT_TYPE"] = "multipart/form-data"

          if req.post?
            imgh = { :image => params.delete(:image)}

            event = booking.create(:event, params)
            event = booking.update(event, imgh) if imgh[:image]

          end
          res.render(view, event: event, action: path(:backend_booking_create))
        end
      end
    end
  end
end
