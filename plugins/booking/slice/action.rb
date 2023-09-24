module Ha2itat::Slices::Booking
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    include Ha2itat.h(:pager)

    def booking
      Ha2itat.adapter(:booking)
    end

  end
end
