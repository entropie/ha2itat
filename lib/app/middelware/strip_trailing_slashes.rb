module Ha2itat
  module Middleware
    class StripTrailingSlash
      def initialize(app)
        @app = app
      end

      def call(env)
        req = Rack::Request.new(env)
        path = req.path

        if req.get? && path != "/" && path.end_with?("/")
          location = path.sub(%r{/+$}, "")
          location = "/" if location.empty?

          query = req.query_string
          location = "#{location}?#{query}" unless query.empty?

          return [301, { "Location" => location, "Content-Type" => "text/plain" }, ["Redirecting..."]]
        end

        @app.call(env)
      end
    end
  end
end
