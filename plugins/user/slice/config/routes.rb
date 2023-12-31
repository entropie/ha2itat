module Ha2itat::Slices::User
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index
    get "/login",      to: "login",   as: :login
    post "/login",     to: "login"
    get "/logout",     to: "logout",  as: :logout
    get "/create",     to: "create"
    post "/create",    to: "create",  as: :create

    get "/edit/:user_id",   to: "edit"
    post "/edit/:user_id",  to: "edit",    as: :edit


    get "/show/:user_id",   to: "show",    as: :show
  end
end
