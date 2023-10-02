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


  def current_path
    request_env["REQUEST_PATH"]
  end

  def current_uri
    request_env["REQUEST_URI"]    
  end

  def active_path(path)
    rp = request_env["REQUEST_URI"]
    if rp.include?("/s/") and path.include?("/s/") and rp.include?(path)
      true
    elsif rp =~ /^#{path}\//
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

  def snippet_page_path(*args)
    ([ Ha2itat::C(:page_prefix) ] + args).join("/")
  end
  
  def path(routename, *args, **hargs)
    Hanami.app["routes"].path(routename.to_sym, **hargs)
  end

  # link to a snippet page
  def slink(*args, text: nil, **opts)
    target_path = snippet_page_path(*args)

    csscls = active_path(target_path) ? "active" : ""
    if ocss = opts.delete(:class)
      csscls = "#{csscls} #{ocss}"
    end
    parsed_opts = opts.inject("") {|opt, m|
      opt << "#{m.first}=\"#{m.last}\" "
    }
    "<a class='snippet-link #{csscls}' href='#{target_path}'#{parsed_opts}>#{text || args.last}</a>"
  end
  alias :sl :slink
  

  # link to a route
  def nlink(routename, desc = nil, opts = {})
    params = opts[:params] || {  }
    if routename.kind_of?(Symbol)
      path = Hanami.app["routes"].path(routename.to_sym, params)
    else
      path = routename
    end

    csscls = active_path(path) ? "active" : ""
    if ocss = opts.delete(:class)
      csscls = "#{csscls} #{ocss}"
    end
    parsed_opts = opts.inject("") {|opt, m|
      opt << "#{m.first}=\"#{m.last}\" "
    }

    "<a class='#{csscls}' href='#{path}'  #{parsed_opts}>#{desc || routename}</a>"
  end
  alias :a :nlink

  def rpath(route, params)
    Hanami.app["routes"].path(route, **params)
  end

  def url_with_calculated_version_hash(url)
    vhash = url + "?hash=" + Ha2itat.calculated_version_hash
  end

end

