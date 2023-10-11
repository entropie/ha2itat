# auto_register: false

require "hanami/slice"

module Ha2itat::Slices::Snippets

  class Slice < Ha2itat::Slices::BackendSlice
    config.root = __dir__

    instance_eval(&Ha2itat::CD(:slice))

    def t
    end
  end
end
