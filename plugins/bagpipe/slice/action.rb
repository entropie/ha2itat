module Ha2itat::Slices::Bagpipe
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def adapter
      Ha2itat.adapter(:bagpipe)
    end

  end
end
