module Ha2itat::Slices::Galleries
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index

    get "/create",      to: "create",  as: :create
    post "/create",     to: "create"
    post "/upload/:slug",        to: "upload",     as: :upload

    post "/setident/:slug/:hash",  to: "setident",     as: :setident

    get "/remove/:slug/:hash",  to: "remove",     as: :remove


    get "/show/:slug", to: "show", as: :show
  end
end
