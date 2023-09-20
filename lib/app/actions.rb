module ActionMethodsCommon
  include WardenCheckToken
  # before :check_token

  class EntryNotFound < ArgumentError;  end

  def error_handler(req, res, exception)
    res.status = 400
    res.body   = "%s: %s" % [exception.class, exception.message]
  end

  def adapter(adptr)
    Ha2itat.adapter(adptr)
  end
end
