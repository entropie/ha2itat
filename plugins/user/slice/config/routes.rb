module Ha2itat::Slices::User
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index
    get "/login",      to: "login",   as: :login
    get "/logout",     to: "logout",  as: :logout
    get "/create",     to: "create"
    post "/create",    to: "create",  as: :create

    get "/edit/:id",   to: "edit"
    post "/edit/:id",  to: "edit",    as: :edit


    get "/show/:id",   to: "show",    as: :show
  end
end
