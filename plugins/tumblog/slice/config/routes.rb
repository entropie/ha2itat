module Ha2itat::Slices::Tumblog
  class Routes < Hanami::Routes
    get "/",                   to: "index",    as: :index

    get "/create",             to: "create",   as: :create
    post "/create",            to: "create"

    get "/show/:id",           to: "show",     as: :show
    post "/settitle/:id",      to: "settitle", as: :settitle

    post "/destroy/:id",        to: "destroy"
    get "/destroy/:id",        to: "destroy",  as: :destroy
    get "/edit/:id",           to: "edit",     as: :edit
    post "/edit/:id",          to: "edit",     as: :edit

    post "/toggle_private/:id", to: "toggleprivate"
    get "/toggle_private/:id", to: "toggleprivate",  as: :toggleprivate
  end
end
