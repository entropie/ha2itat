module Ha2itat::Slices::Backend
  class Routes < Hanami::Routes
    get "/", to: "index", as: "index"
  end
end
