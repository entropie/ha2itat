module Ha2itat::Slices::Entromind
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index
  end
end
