module Ha2itat::Slices
  module Booking
    module Views
      class Create < View
         instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
