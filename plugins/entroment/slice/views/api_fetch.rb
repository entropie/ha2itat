module Ha2itat::Slices
  module Entroment
    module Views
      class APIFetch < View
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
