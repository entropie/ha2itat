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

      before :set_default_meta
    }

    Slice = proc {
      environment(:development) do
        config.actions.content_security_policy[:script_src] = "'self' 'unsafe-eval'"
        config.actions.content_security_policy[:font_src] =
          '\'self\' data: https://fonts.googleapis.com https://fonts.gstatic.com https://maxcdn.bootstrapcdn.com'
      end

    }

    View = proc {
      include ViewMethodsCommon
      include Helper::Translation

    }
  end

end
