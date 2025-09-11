module Ha2itat::Slices::Tumblogtools
  class Routes < Hanami::Routes
    get "/feed(.:format)*fragments",     to: "feed",   as: :feed
  end
end
