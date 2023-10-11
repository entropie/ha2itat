module Ha2itat::Slices
  module Tumblog
    module Views
      class Edit < View
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
