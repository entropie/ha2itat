module Ha2itat::Slices::Blogtools
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def adapter
      Ha2itat.adapter(:blog)
    end
  end
end
