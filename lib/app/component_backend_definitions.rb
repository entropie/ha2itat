module Ha2itat

  def self.CD(obj)
    newconst = obj.to_s.capitalize
    ComponentBackendDefinitions.const_get(newconst)
  end

  module ComponentBackendDefinitions

    Action = proc {
      include ActionMethodsCommon

      before :check_token
      before :refuse_unless_auhtenticated!
    }

    Slice = proc {
      environment(:development) do
        config.actions.content_security_policy[:script_src] = "'self' 'unsafe-eval'"
      end
    }

    View = proc {
      include ViewMethodsCommon
    }
  end

end
