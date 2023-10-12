module ActionMethodsCommon
  include WardenCheckToken

  class EntryNotFound < ArgumentError;  end

  def set_meta(view, req, **kwargs)
    if view
      view.exposures.add(:meta, proc{ Ha2itat::Meta.new(view, req, **kwargs) }, layout: true)
    end
  end

  def set_default_meta(req, res)
    hash = {}
    if req.env["REQUEST_PATH"].split("/")[1] == "backend"
      hash[:title] = "[be]"
    end
    set_meta(view, req, **hash)
  end

  def gallery_img(gal, ident)
    Ha2itat.adapter(:galleries).find(gal.to_s).images(ident.to_s)
  end

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

  def params_path(params)
    ret = params[:fragments] || ""
    ret = [ret].flatten
    ret = ret.
            map{ |e| e.force_encoding(Encoding::UTF_8) }.
            map{ |r| CGI.unescape(r) }
  end


  def reject_unless_authenticated!(req, res)
    if req.env["REQUEST_PATH"] != path(:backend_user_login)
      unless req.env["warden"] and req.env["warden"].user
        res.redirect_to path(:backend_user_login)
        halt 401
      end
    end
  end
end
