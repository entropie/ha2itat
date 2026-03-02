module Ha2itat::Slices::Polygram
  class Routes < Hanami::Routes
    scope "backend" do
      scope  "polygram" do
        get  "/",               to: "index",  as: :index
        get  "/create",         to: "create",  as: :create
        post "/create",         to: "create"

        get  "/:id/destroy",    to: "destroy",  as: :destroy

        get  "/:id/show",       to: "show",  as: :show

        get  "/:id/observe/:mid",    to: "observe",  as: :observe
        get  "/:id/read/:mid",       to: "read",  as: :read

        get  "/:id/attach",          to: "attach",  as: :attach
        post "/:id/attach",          to: "attach"

        get  "/:id/detach/:mid",     to: "detach",  as: :detach


        post  "/:id/observe/:mid",   to: "observe"
        post  "/:id/read/:mid",      to: "read"


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
