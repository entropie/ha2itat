module ActionMethodsCommon
  include WardenCheckToken

  class EntryNotFound < ArgumentError;  end

  def routes
    Hanami.app["routes"]
  end

  def path(...)
    routes.path(...)
  end

  def session_user(req)
    req.env["warden"].user
  end

  def redirect_target_from_request(req)
    req.params[:goto]
  end

  def error_handler(req, res, exception)
    res.status = 400
    res.body  = "%s:\n %s" % [exception.class, exception.message]
  end

  def adapter(adptr)
    Ha2itat.adapter(adptr)
  end

  def reject_unless_authenticated!(req, res)
    if req.env["REQUEST_PATH"] != path(:backend_user_login)
      unless req.env["warden"].user
        res.redirect_to path(:backend_user_login)
        halt 401
      end
    end
  end
end
