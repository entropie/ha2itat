module Ha2itat::Slices
  module Snippet
    module Views
      class Edit < View
        instance_eval(&Ha2itat::CD(:view))


        expose :snippet
      end
    end
  end
end                      
