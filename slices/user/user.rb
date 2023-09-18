# auto_register: false

require "hanami/slice"

module Ha2itat::Slices::User


  class Slice < Hanami::Slice
    config.root = __dir__
    # config.actions.content_security_policy[:script_src] = "'self' 'unsafe-eval'"
  end
end
