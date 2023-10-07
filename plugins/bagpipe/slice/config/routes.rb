module Ha2itat::Slices::Bagpipe
  class Routes < Hanami::Routes
    get "/",      to: "index"
    get "/play/*fragments",      to: "play",   as: :play
    get "/player/*fragments",      to: "player",   as: :player
    get "/*fragments",           to: "index",   as: :index
  end
end
