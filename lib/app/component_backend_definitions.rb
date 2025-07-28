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

      before :follow_redirect

      include Helper::Translation::Actions
      before :locales_setup

      include Hanami::Action::Session
      before :set_default_meta

    }

    Slice = proc {
      config.actions.content_security_policy = false
      config.middleware.use Ha2itat::Middelware::SecureHeaders

      # environment(:production) do
      # end

      # environment(:development) do
      # end

      config.actions.sessions = :cookie, {
        key: SESSION_KEY,
        secret: Ha2itat.quart.secret,
        expire_after: SESSION_EXPIRY_TIME_IN_SECONDS
      }
    }

    View = proc {
      include ViewMethodsCommon
      include Helper::Translation
    }
  end

end
