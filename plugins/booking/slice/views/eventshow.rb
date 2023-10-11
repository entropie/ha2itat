module Ha2itat::Slices
  module Booking
    module Views
      class Eventshow < View
        instance_eval(&Ha2itat::CD(:view))

        expose :event
      end
    end
  end
end
