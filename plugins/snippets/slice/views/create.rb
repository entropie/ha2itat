module Ha2itat::Slices
  module Snippets
    module Views
      class Create < View
        expose :snippet

        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end                      
