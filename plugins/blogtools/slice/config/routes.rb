module Ha2itat::Slices::Blogtools
  class Routes < Hanami::Routes
    get "/feed(.:format)",   to: "feed",   as: :feed
    get "/api/posts",        to: "api",    as:  :api
  end
end
