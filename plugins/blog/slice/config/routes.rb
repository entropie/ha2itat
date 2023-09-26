module Ha2itat::Slices::Blog
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index
    get "/create",     to: "create",  as: :create
    post "/create",    to: "create"
    get "/show/:slug", to: "show",    as: :show


    get "/toggle_publish/:slug", to: "togglepublish", as: :toggle_publish
    get "/show/:slug",           to: "show", as: :show
    get "/show/raw/:slug",       to: "withoutlayout", as: :show_withoutlayout
    get "/edit/:slug",           to: "edit", as: :edit
    post "/edit/:slug",           to: "edit"
    get "/destroy/:slug",           to: "destroy", as: :destroy

  end
end
