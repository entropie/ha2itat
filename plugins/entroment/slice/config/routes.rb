module Ha2itat::Slices::Entroment
  class Routes < Hanami::Routes
    scope "backend" do
      scope "entroment" do
        get "/",               to: "index",   as: :index
        get "/show/:id",       to: "show",   as: :show
        get "/edit/:id",       to: "edit",   as: :edit
      end
    end

    # scope "api" do
    #   scope "entromind/v1" do
    #     get "/fetch/:id",       to: "fetch",   as: :fetch
    #   end
    # end
  end
end
