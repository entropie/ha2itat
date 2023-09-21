module Ha2itat::Slices
  module Snippet
    module Views
      class Edit < View
         instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end                      
