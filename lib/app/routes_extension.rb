module Ha2itat

  def self.module_routes
    proc {

      get '/assets/*path',          to: Rack::Directory.new( Ha2itat.quart.media_path("public") )
      get '/data/*path',            to: Rack::Directory.new( Ha2itat.quart.media_path("public") )

      if Ha2itat.quart.plugins.enabled?(:icons)
        slice :icons,           at: "/icons/"
      end


      if (Hanami.app.slices[:backend] rescue false)
        slice :backend,             at: "/backend"
      end

      if (Hanami.app.slices[:user] rescue false)
        slice :user,                at: "/backend/user"
      end

      if (Hanami.app.slices[:snippets] rescue false)
        slice :snippets,           at: "/backend/snippets"

        prefix = Ha2itat::C(:page_prefix)

        get "#{prefix}/:slug",            to: "pages.page", as: :page
        get "#{prefix}/:slug/*fragments", to: "pages.page", as: :page
      end

      if (Hanami.app.slices[:booking] rescue false)
        slice :booking,            at: "/backend/booking"
      end

      if (Hanami.app.slices[:blog] rescue false)
        slice :blog,            at: "/backend/blog"
      end

      if (Hanami.app.slices[:tumblog] rescue false)
        slice :tumblog,         at: "/backend/tumblog"
      end

      if (Hanami.app.slices[:zettel] rescue false)
        slice :zettel,         at: "/backend/zettel"
      end

      if (Hanami.app.slices[:galleries] rescue false)
        get '/galleries/*path', to: Rack::Directory.new( Ha2itat.quart.media_path("public") ), as: :image
        slice :galleries,       at: "/backend/galleries"
      end

      if (Hanami.app.slices[:i18n] rescue false)
        slice :i18n, at: "/backend/i18n"
      end
    }
  end
  
end
