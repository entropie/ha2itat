module Ha2itat::Slices
  module Booking
    module Views
      class Index < View
         instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end                      
