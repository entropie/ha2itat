module Ha2itat::Slices::Zettel
  class Routes < Hanami::Routes
    get  "/",                to: "index",      as: :index

    get  "/show/:id",     to: "show",          as: :show

    get  "/edit/:id",     to: "edit",          as: :edit
    post "/edit/:id",     to: "edit"
    post "/upload/:id",   to: "upload",        as: :upload
    get  "/create",       to: "create",        as: :create
    get  "/destroy/:id",  to: "destroy",       as: :destroy
    get  "/references/:slug",  to: "references",       as: :references

    post "/create",       to: "create"
  end
end
