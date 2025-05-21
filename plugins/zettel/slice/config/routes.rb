module Ha2itat::Slices::Zettel
  class Routes < Hanami::Routes
    scope "backend/zettel" do
      get  "/",                to: "index",      as: :index

      get  "/show/:id",     to: "show",          as: :show

      get  "/edit/:id",     to: "edit",          as: :edit
      post "/edit/:id",     to: "edit"
      post "/upload/:id",   to: "upload",        as: :upload
      get  "/create",       to: "create",        as: :create
      get  "/destroy/:id",  to: "destroy",       as: :destroy

      get  "/references",   to: "references",    as: :reference_base
      get  "/references/:ref",   to: "references",    as: :references

      post "/create",       to: "create"
    end
    get '/_zettel/data/*fragments', to: "read", as: :zl_read
  end
end
