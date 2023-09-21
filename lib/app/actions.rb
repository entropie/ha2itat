module ActionMethodsCommon
  include WardenCheckToken
  # before :check_token

  class EntryNotFound < ArgumentError;  end

  def routes
    Hanami.app["routes"]
  end

  def path(...)
    routes.path(...)
  end


  def error_handler(req, res, exception)
    res.status = 400
    res.body  = "%s:\n %s" % [exception.class, exception.message]
  end

  def adapter(adptr)
    Ha2itat.adapter(adptr)
  end

  # Fixme:
  def t(*args)
    %Q(<span class='T-error'>%s</span>) % [args.join("-")]
  end
  
end
