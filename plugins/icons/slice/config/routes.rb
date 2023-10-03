module Ha2itat::Slices::Icons
  class Routes < Hanami::Routes
    get "/feather/sprite",            to: "sprite" ,   as: :sprite
  end
end
