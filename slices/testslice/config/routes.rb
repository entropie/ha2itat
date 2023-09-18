module Ha2itat::Slices::TestSlice
  class Routes < Hanami::Routes
    get "/", to: "test_action"
    get "/testaction", to: "test_action"
  end
end
