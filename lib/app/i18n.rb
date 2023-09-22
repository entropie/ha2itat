require "r18n-core"
require "cgi"

module Ha2itat

  module I18n

    def self.backend_places
      [Ha2itat.root("assets", "i18n")]
    end

    def self.default_places=(obj)
      @default_places = obj
    end

    def self.default_places
      @default_places ||= [Ha2itat.quart.media_path("i18n")]
    end

    include R18n

    def self.init
      Ha2itat.log "init R18n"
      if Ha2itat.quart.development?
        Ha2itat.log "clearing cache"
        R18n.clear_cache!
      end
      
      R18n.default_places = [backend_places, default_places].flatten

      i18n = ::R18n::I18n.new(
        "en", ::R18n.default_places, off_filters: :untranslated, on_filters: :untranslated_html
      )

      ::R18n.set(i18n)
    end
  end

  module Helper::Translation

    def r18n
      ::R18n.get
    end

    def t(*params)
      ::R18n.get.t(*params)
    end

    def l(*params)
      R18n.get.l(*params)
    end  
  end

end
