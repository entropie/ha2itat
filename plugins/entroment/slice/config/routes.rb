module Ha2itat::Slices::Entroment
  class Routes < Hanami::Routes
    scope "backend" do
      scope "entroment" do
        get "/",               to: "index",  as: :index
        get "/show/:id",       to: "show",   as: :show
        get "/edit/:id",       to: "edit",   as: :edit
        post "/edit/:id",      to: "edit"
        get "/destroy/:id",    to: "destroy",as: :destroy
        get "/create",         to: "create", as: :create
        post "/create",        to: "create"

        get "/decks",          to: "decks", as: :decks
        get "/deck/:name",     to: "deck", as: :deck
        get "/deck/:name/card/:cardid", to: "card", as: :card
        get "/deck/:name/rate/:cardid", to: "rate", as: :rate

        get "/sessions",       to: "sessions", as: :sessions
        get "/deck/:name/session/",  to: "session", as: :session_start
        get "/deck/:name/session/finalize",  to: "sessionend", as: :session_end
        get "/deck/:name/session/:sessionid",  to: "session", as: :session
      end
    end

    scope "api" do
      scope "entroment/v1" do
        get "/fetch",           to: "api_fetch"
        get "/fetch/:id",       to: "api_fetch",   as: :api_fetch
        get "/post",            to: "api_create",  as: :api_create
        post"/post",            to: "api_create"
      end
    end
  end
end
