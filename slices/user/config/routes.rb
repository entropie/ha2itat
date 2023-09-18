module Ha2itat::Slices::User
  class Routes < Hanami::Routes
    get "/",       to: "index",   as: :index
    get "/login",  to: "login",   as: :login
    get "/logout", to: "logout",  as: :logout
  end
end
