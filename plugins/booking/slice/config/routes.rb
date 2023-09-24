module Ha2itat::Slices::Booking
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index

    post "/create",    to: "create"
    get "/create",     to: "create",  as: :create


    get "/event/:slug/archive",        to: "index", as: :event_archive

    get "/event/:slug/show",           to: "eventshow", as: :event_show
    get "/event/:slug/edit",           to: "eventedit", as: :event_edit
    post "/event/:slug/edit",          to: "eventedit"

    get "/event/:slug/destroy",        to: "eventdestroy", as: :event_destroy
    get "/event/:slug/toggle_publish", to: "eventtogglepublish", as: :event_toggle_publish
  end
end

