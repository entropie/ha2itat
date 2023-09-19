module Ha2itat::Slices::Backend
  class Routes < Hanami::Routes
    get "/", to: "test", as: "index"
  end
end
