module Ha2itat::Slices::Bagpipe
  class Routes < Hanami::Routes
    scope "backend/bagpipe" do
      get "/",      to: "index"
      get "/play/*fragments",      to: "play",   as: :play
      get "/player/*fragments",      to: "player",   as: :player
      get "/*fragments",           to: "index",   as: :index
    end
    get '/_bagpipe/*fragments', to: "read", as: :bp_read
  end
end
