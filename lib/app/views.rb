module ViewMethodsCommon
  def active_path(path)
    env = self._context.request.env
    rp = env["REQUEST_URI"]
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
    self._context.request.env["warden"].user.class
  end
  
  def path(routename)
    Hanami.app["routes"].path(routename.to_sym)
  end

  # Add your view helpers here
  def nlink(routename, desc = nil, opts = {})
    params = opts[:params] || {  }
    path = Hanami.app["routes"].path(routename.to_sym, params)
    csscls = active_path(path) ? "active" : ""

    if opts[:class]
      csscls = "#{csscls} #{opts[:class]}"
    end
    
    "<a class='#{csscls}' href='#{path}'>#{desc || routename}</a>"
  end
end

