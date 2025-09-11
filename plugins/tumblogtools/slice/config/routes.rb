module Ha2itat::Slices::Tumblogtools
  class Routes < Hanami::Routes
    get "/feed(.:format)*fragments",                    to: "feed",   as: :feed
    get "/api/bloogmarks/v1/posts(.:format)*fragments", to: "api",    as:  :api
  end
end
