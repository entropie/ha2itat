module Ha2itat::Slices::Booking
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index
  end
end
