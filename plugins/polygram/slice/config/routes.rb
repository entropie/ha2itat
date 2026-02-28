module Ha2itat::Slices::Polygram
  class Routes < Hanami::Routes
    scope "backend" do
      scope  "polygram" do
        get  "/",               to: "index",  as: :index
        get  "/create",         to: "create",  as: :create
        post "/create",         to: "create"
        get  "/show/:id",       to: "show",  as: :show

        get  "/observe/:id/:mid",    to: "observe",  as: :observe
        get  "/read/:id/:mid",       to: "read",  as: :read

        post  "/observe/:id/:mid",   to: "observe"
        post  "/read/:id/:mid",      to: "read"


      end
    end

    # scope "api" do
    #   scope "entroment/v1" do
    #     get "/fetch",           to: "api_fetch"
    #     get "/fetch/:id",       to: "api_fetch",   as: :api_fetch
    #     get "/post",            to: "api_create",  as: :api_create
    #     post"/post",            to: "api_create"
    #   end
    # end
  end
end
