module Ha2itat::Slices::Snippet
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index

    get "/create",     to: "create"
    post "/create",    to: "create",  as: :create

    get "/edit/:id",   to: "edit"
    post "/edit/:id",  to: "edit",    as: :edit


    get "/show/:id",   to: "show",    as: :show


  end
end
