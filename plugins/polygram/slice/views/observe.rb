module Ha2itat::Slices
  module Polygram
    module Views
      class Observe < View
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
