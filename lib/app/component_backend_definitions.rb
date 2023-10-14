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

      format :html, :json
    }

    Slice = proc {
      environment(:development) do
        config.actions.content_security_policy[:script_src] = "'self' 'unsafe-inline' 'unsafe-eval' http: https:"
        config.actions.content_security_policy[:frame_src] =  "self 'unsafe-inline' 'unsafe-eval' http: https:"
        config.actions.content_security_policy[:font_src] =
          '\'self\' data: https://fonts.googleapis.com https://fonts.gstatic.com https://maxcdn.bootstrapcdn.com'

      end
      config.actions.format :html, :json
    }

    View = proc {
      include ViewMethodsCommon
      include Helper::Translation

    }
  end

end
