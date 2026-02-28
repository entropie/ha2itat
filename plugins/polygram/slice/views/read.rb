module Ha2itat::Slices
  module Polygram
    module Views
      class Read < View
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
