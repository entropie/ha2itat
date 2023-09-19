module ViewMethodsCommon
  def env?(which)
    yield if Hanami.env == which.to_sym
  end

  def request_env(arg = nil)
    renv = self._context.request.env
    unless arg
      renv
    else
      renv[arg]
    end
  end

  def active_path(path)
    rp = request_env["REQUEST_URI"]
    if rp.include?("/s/") and path.include?("/s/") and rp.include?(path)
      true
    elsif rp =~ /^#{path}$\//
      true
    else
      path == rp
    end
  rescue
    false
  end

  def session_user
    request_env["warden"].user rescue nil
  end
  
  def path(routename, **hargs)
    Hanami.app["routes"].path(routename.to_sym, **hargs)
  end

  def nlink(routename, desc = nil, opts = {})
    params = opts[:params] || {  }
    if routename.kind_of?(Symbol)
      path = Hanami.app["routes"].path(routename.to_sym, params)
    else
      path = routename
    end

    csscls = active_path(path) ? "active" : ""

    if opts[:class]
      csscls = "#{csscls} #{opts[:class]}"
    end
    
    "<a class='#{csscls}' href='#{path}'>#{desc || routename}</a>"
  end

  def rpath(route, params)
    Hanami.app["routes"].path(route, **params)
  end

  def url_with_calculated_version_hash(url)
    vhash = url + "?hash=" + Ha2itat.calculated_version_hash
  end
end

