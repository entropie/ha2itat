module Ha2itat::Slices::Blog
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index
  end
end
