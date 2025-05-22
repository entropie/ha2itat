module Ha2itat
  module Middelware

    class SecureHeaders

      DefaultHeaders = {
        "X-Frame-Options" => "SAMEORIGIN",
        "X-Content-Type-Options" => "nosniff",
        "X-XSS-Protection" => "0",
        "Referrer-Policy" => "strict-origin-when-cross-origin",
        #{}"Permissions-Policy" => "geolocation=(), microphone=(), camera=()",
        "Content-Security-Policy" => []
      }

      DefaultContentSecurityPolicy = [
        "default-src 'none'",
        "base-uri 'self'",
        "form-action 'self'",
        "frame-ancestors 'self'",
        "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
        "style-src 'self' 'unsafe-inline'",
        "img-src 'self' https: data:",
        "connect-src 'self' https://i.imgur.com",
        "font-src 'self' https: data:",
        "media-src 'self'",
        "object-src 'none'"
      ]

      def self.headers=(hash)
        @headers = hash
      end

      def self.content_security_policy=(arr)
        @content_security_policy = arr
      end


      def self.headers
        hdrs = (@headers || DefaultHeaders)
        hdrs["Content-Security-Policy"] = content_security_policy
        hdrs
      end

      def self.content_security_policy
        (@content_security_policy || DefaultContentSecurityPolicy).join("; ")
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        status, hdrs, body = @app.call(env)
        hdrs.merge!(self.class.headers)
        [status, hdrs, body]
      end
    end

    class SecureHeadersDev < SecureHeaders
    end
  end
end
