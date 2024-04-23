module Ha2itat::Slices
  module Tumblog
    module Views
      class Clytdlp < View
        instance_eval(&Ha2itat::CD(:view))

        expose :content
      end
    end
  end
end
