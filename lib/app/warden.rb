require "warden"

module WardenCheckToken

  def check_token(request, response)
    goto = proc{|path| response.redirect_to path }

    if request.env["warden"] and request.env["warden"].user and request.params[:redirect]
      goto.call(request.params[:redirect])
    end

    return false if not request.params[:token] or request.env["warden"].user
    if ::Warden::Strategies[:token]
      user_authenticated = request.env["warden"].authenticate(:token)
      if user_authenticated
        if request.params[:goto]
          goto.call(request.params[:goto])
        end
        return true
      end
    end
  end
end


Warden::Strategies.add(:password) do

  def valid?
    params['username'] || params['password']
  end

  def authenticate!
    user = Ha2itat.adapter(:user).by_name(params['name'])
    return false unless user
    if u = user.authenticate(params['password'])
      success!(u)
    else
      fail("nope")
    end
  rescue
    p $!
    false
  end
end

Warden::Strategies.add(:token) do
  def valid?
    params["token"]
  end

  def authenticate!
    tkn = params["token"]

    u = Ha2itat.adapter(:user).by_token(tkn)
    u.nil? ? fail!("Could not log in") : success!(u)
  rescue
    p $!
    false
  end
end


Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  Ha2itat.adapter(:user).by_id(id)
end
