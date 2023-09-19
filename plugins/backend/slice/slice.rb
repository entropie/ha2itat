# auto_register: false

require "hanami/slice"

module Ha2itat::Slices::Backend
  
  class Slice < Ha2itat::Slices::BackendSlice
    config.root = __dir__

    class_eval(&content_security_policy)
  end
end
