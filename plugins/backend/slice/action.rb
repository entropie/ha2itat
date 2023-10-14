module Ha2itat::Slices::Backend

  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))
  end
end
