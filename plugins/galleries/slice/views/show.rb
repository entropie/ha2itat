module Ha2itat::Slices
  module Galleries
    module Views
      class Show < View
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
