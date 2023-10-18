module Ha2itat

  def self.module_routes
    slices = Hanami.app.slices.keys
    proc {

      get '/assets/*path',      to: Rack::Directory.new( Ha2itat.quart.media_path("public") )
      get '/data/*path',        to: Rack::Directory.new( Ha2itat.quart.media_path("public") )

      if Ha2itat.quart.plugins.enabled?(:icons)
        slice :icons,           at: "/icons/"
      end


      if slices.include?(:backend)
        slice :backend,         at: "/backend"
      end

      if slices.include?(:user)
        slice :user,            at: "/backend/user"
      end

      if slices.include?(:snippets)
        slice :snippets,        at: "/backend/snippets"
        prefix = Ha2itat::C(:page_prefix)
        get "#{prefix}/:slug",            to: "pages.page", as: :page
        get "#{prefix}/:slug/*fragments", to: "pages.page", as: :page
      end

      if slices.include?(:booking)
        slice :booking,         at: "/backend/booking"
      end

      if slices.include?(:blog)
        slice :blog,            at: "/backend/blog"

        if slices.include?(:blogtools)
          slice :blogtools,       at: "/"
        end
      end

      if slices.include?(:tumblog)
        get '/_tumblog/data/*fragments', to: proc{ |env| Ha2itat::Slices::Tumblog::Actions::Read.new.call(env) }, as: :tl_read
        slice :tumblog,         at: "/backend/tumblog"
      end

      if slices.include?(:zettel)
        get '/_zettel/data/*fragments', to: proc{ |env| Ha2itat::Slices::Zettel::Actions::Read.new.call(env) }, as: :zl_read
        slice :zettel,          at: "/backend/zettel"
      end

      if slices.include?(:bagpipe)
        get '/_bagpipe/*fragments', to: proc{ |env| Ha2itat::Slices::Bagpipe::Actions::Read.new.call(env) }, as: :bp_read
        slice :bagpipe,         at: "/backend/bagpipe"
      end

      if slices.include?(:galleries)
        get '/galleries/*path', to: Rack::Directory.new( Ha2itat.quart.media_path("public") ), as: :image
        slice :galleries,       at: "/backend/galleries"
      end

      if slices.include?(:i18n)
        slice :i18n,            at: "/backend/i18n"
      end
    }
  end

end
