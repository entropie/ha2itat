module Ha2itat::Slices; end

class  Ha2itat::Slices::BackendSlice < Hanami::Slice
  def self.content_security_policy
    proc { 
      environment(:development) do
        config.actions.content_security_policy[:script_src] = "'self' 'unsafe-eval'"
      end
    }
  end
end
