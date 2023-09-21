require "warden"

module WardenCheckToken
  def check_token(request, response)
    # p request.params[:token]
    # p request.env["warden"].user

    goto = proc{|path| response.redirect_to path }

    return false if not request.params[:token] or request.env["warden"].user

    if ::Warden::Strategies[:token]
      user_authenticated = request.env["warden"].authenticate(:token)
      if user_authenticated and request.params[:goto]
        goto.call(request.params[:goto])
      else
        goto.call(path(:backend_index))
      end
    end
  # rescue
  #   false
  end
end


Warden::Strategies.add(:password) do

  def valid?
    params['username'] || params['password']
  end
  
  def authenticate!
    u = Ha2itat.adapter(:user).user(params['username']).authenticate(params['password'])
    u.nil? ? fail!("Could not log in") : success!(u)
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
