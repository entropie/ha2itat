module Ha2itat::Slices::Snippet

  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))
  end

end

