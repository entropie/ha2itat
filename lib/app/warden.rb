require "warden"

module WardenCheckToken

  def check_token(request, response)
    redirect_target = request.params[:goto] || request.params[:redirect]
    maybe_redirect = -> { response.redirect_to(redirect_target) if redirect_target }

    warden = request.env["warden"]
    return false unless warden

    if warden.user
      maybe_redirect.call
      return false
    end

    return false unless request.params[:token]

    if ::Warden::Strategies[:token]
      if warden.authenticate(:token)
        maybe_redirect.call
        return true
      end
    end

    false
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
