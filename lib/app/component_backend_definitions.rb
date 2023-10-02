module Ha2itat

  def self.CD(obj)
    newconst = obj.to_s.capitalize
    ComponentBackendDefinitions.const_get(newconst)
  end

  module ComponentBackendDefinitions

    Action = proc {
      include ActionMethodsCommon

      before :check_token
      before :reject_unless_authenticated!

      include Helper::Translation::Actions
      before :locales_setup

      include Hanami::Action::Session
    }

    Slice = proc {
      environment(:development) do
        config.actions.content_security_policy[:script_src] = "'self' 'unsafe-eval'"
      end

    }

    View = proc {
      include ViewMethodsCommon
      include Helper::Translation

    }
  end

end
