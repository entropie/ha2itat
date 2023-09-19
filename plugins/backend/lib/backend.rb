module Plugins
  module Backend
    def self.order
      -5
    end

    def self.get_default_adapter_initialized
      self
    end
  end
end
