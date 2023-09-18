# auto_register: false

require "hanami/slice"

module Ha2itat::Slices::TestSlice

  class Slice < Hanami::Slice
    config.root = __dir__
  end

end
