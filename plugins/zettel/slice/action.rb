module Ha2itat::Slices::Zettel
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def adapter
      Ha2itat.adapter(:zettel)
    end
  end
end
