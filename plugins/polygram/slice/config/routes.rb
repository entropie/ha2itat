module Ha2itat::Slices::Polygram
  class Routes < Hanami::Routes
    scope "backend" do
      scope  "polygram" do
        get  "/",               to: "index",  as: :index
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
