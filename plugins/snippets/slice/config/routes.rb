module Ha2itat::Slices::Snippets
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index

    get "/create",     to: "create"
    post "/create",    to: "create",  as: :create

    get "/edit/:slug", to: "edit",    as: :edit
    post "/edit/:slug",to: "edit"

    get "/destroy/:slug", to: "destroy",    as: :destroy


    get "/show/:slug",   to: "show",    as: :show


  end
end
