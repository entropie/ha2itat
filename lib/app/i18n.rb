require "cgi"
require "r18n-core"

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

    def self.init(locale = ::R18n::I18n.default )

      R18n.clear_cache! if Ha2itat.quart.development?
      
      R18n.default_places = [backend_places, default_places].flatten

      i18n = ::R18n::I18n.new(
        locale, ::R18n.default_places, off_filters: :untranslated, on_filters: :untranslated_html
      )

      ::R18n.thread_set(i18n)
    end
  end

  module Helper::Translation

    module Actions

      def self.included(o)
        o.class_eval do
          before :locales_setup
        end
      end

      def locales_setup(req, res)
        locales = ::R18n::I18n.parse_http(req.env['HTTP_ACCEPT_LANGUAGE'])

        if req.params[:locale]
          locales.unshift(req.params[:locale])
        elsif res.session[:locale]
          locales.unshift(res.session[:locale])
        end

        Ha2itat::I18n.init(locales)
      end
    end

    def r18n
      ::R18n.get
    end

    def t(*params)
      ::R18n.get.t(*params)
    end
    module_function :t

    def l(*params)
      R18n.get.l(*params)
    end  
  end

end

# foobar: !!icon
#   i: icon-circle
#   t: text
#
R18n::Filters.add('icon', :icon) do |content, config, opt|
  if Ha2itat.quart.plugins.enabled?(:icons)
    ::Plugins::Icons.icon(content['i'])
  else
    ret = nil
    
    # if opt is supplied we get alternate translation
    if opt
      current = ::R18n.get
      opt.split(".").each do |seg|
        unless current
          break
        end
        current = current[seg]
      end

      ret = current
    end
    ret || content['t']
  end
end
