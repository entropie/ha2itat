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

  def _csrf_field
    "<input type='hidden' name='_csrf_token' value='#{_context.csrf_token}'>"
  end

  def current_path
    request_env["REQUEST_PATH"] || "/"
  end

  def current_uri
    request_env["REQUEST_URI"]
  end

  def active_segment
    current_path.split("/")[1]
  end

  def current_segment(seg)
    active_segment == seg.to_s
  end

  def active_path(path)
    rp = request_env["REQUEST_URI"]
    rp = rp.split("?").first
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

  def _link(href:, text:, css: nil, opts:)
    css = css || ""
    if ocss = opts.delete(:class)
      css = "#{css} #{ocss}"
    end

    parsed_opts = opts.inject("") {|opt, m|
      opt << " #{m.first}=\"#{m.last}\""
    }
    "<a class='#{css}' href='#{href}'#{parsed_opts}>#{text}</a>"
  end

  # link to a snippet page
  def slink(*args, text: nil, **opts)

    target_path = snippet_page_path(*args)

    csscls = active_path(target_path) ? " active" : ""

    _link(href: target_path, text: text || target_path, css: "snippet-page-link#{csscls}", opts: opts)
  end

  def segment_link(routename, desc = nil, opts = {})
    params = opts[:params] || {  }
    path =
      if routename.kind_of?(Symbol)
        Hanami.app["routes"].path(routename.to_sym, params)
      else
        routename
      end
    csscls = current_segment(path.split("/")[1]) ? "active" : ""
    _link(href: path, text: desc || routename, css: csscls, opts: opts)
  end

  # link to a route
  def nlink(routename, desc = nil, opts = {})
    params = opts[:params] || {  }
    path = if routename.kind_of?(Symbol)
      Hanami.app["routes"].path(routename.to_sym, params)
    else
      routename
    end
    csscls = active_path(path) ? "active" : ""
    _link(href: path, text: desc || routename, css: csscls, opts: opts)
  end


  def rpath(route, params)
    Hanami.app["routes"].path(route, **params)
  end

  def url_with_calculated_version_hash(url)
    vhash = url + "?hash=" + Ha2itat.calculated_version_hash
  end

end
