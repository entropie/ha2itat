module Ha2itat::Slices
  module User
    module Views
      class Login < View
        instance_eval(&Ha2itat::CD(:view))
        config.layout = "login"
      end
    end
  end
end
