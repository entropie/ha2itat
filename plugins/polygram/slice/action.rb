module Ha2itat::Slices::Polygram
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def adapter
      Ha2itat.adapter(:polygram)
    end

    def observation_for(caze, user, mid)
      observations = adapter.observations_for(caze).select{ |rdng| rdng.user.id == user.id }
      observations.reject!{ |obs| obs.mid != mid }
      return observations.shift
    end

    def reading_for(caze, user, mid)
      readings = adapter.readings_for(caze).select{ |rdng| rdng.user.id == user.id }
      readings.reject!{ |obs| obs.mid != mid }
      return readings.shift
    end

  end
end
