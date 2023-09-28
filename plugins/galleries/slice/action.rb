module Ha2itat::Slices::Galleries
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def adapter
      Ha2itat.adapter(:galleries)
    end
  end
end
