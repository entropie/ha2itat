module Ha2itat::Slices
  module Entroment
    module Views
      class Sessions < View
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
