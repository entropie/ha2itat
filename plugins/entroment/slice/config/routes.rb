module Ha2itat::Slices::Entroment
  class Routes < Hanami::Routes
    scope "backend" do
      scope "entroment" do
        get "/",               to: "index",  as: :index
        get "/show/:id",       to: "show",   as: :show
        get "/edit/:id",       to: "edit",   as: :edit
        post "/edit/:id",      to: "edit"
        get "/destroy/:id",    to: "destroy",as: :destroy
        get "/create",         to: "create", as: :create
        post "/create",        to: "create"
      end
    end

    scope "api" do
      scope "entroment/v1" do
        get "/fetch",           to: "api_fetch"
        get "/fetch/:id",       to: "api_fetch",   as: :api_fetch
        get "/post",            to: "api_create",  as: :api_create
        post"/post",            to: "api_create"
      end
    end
  end
end