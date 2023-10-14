module Ha2itat::Slices

  module Blogtools
    module Views
      module Helpers
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
