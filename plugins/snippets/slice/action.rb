module Ha2itat::Slices::Snippets

  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    before :refuse_unless_auhtenticated!
  end

end

