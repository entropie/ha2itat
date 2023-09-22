module Plugins
  module Booking
    DEFAULT_ADAPTER = :File


    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    # module BookingViewMethods
    # end

    # module BookingControllerMethods
    #   def booking
    #     Ha2itat.adapter(:booking).with_user(session_user)
    #   end

    # end
  end
end
