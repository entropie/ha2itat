module Ha2itat::Slices
  module Snippets
    module Views
      class Edit < View
        instance_eval(&Ha2itat::CD(:view))


        expose :snippet
      end
    end
  end
end
