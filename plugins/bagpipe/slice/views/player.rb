module Ha2itat::Slices
  module Bagpipe
    module Views
      class Player < View
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end                      
