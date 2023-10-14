module Ha2itat
  class Meta

    attr_reader :title, :desc, :image, :type, :author, :color_scheme, :url

    attr_accessor :elements

    DEFAULTS = proc {
      add_meta charset: "utf-8"
      add_meta name:    "viewport", content: "width=device-width, initial-scale=1"

      add_meta name:    "title", content: app_title
      add_meta name:    "description", content: app_desc
      add_meta name:    "color-scheme", content: color_scheme
      add_title app_title

      if Ha2itat.quart.plugins.enabled?(:blog)
        add_link rel: "alternate", type: "application/rss+xml", title: Ha2itat.C(:title), href: routes.path(:feed)
      end
    }

    SOCIAL_MEDIA = proc {
      add_meta property: "og:type", content: type || "website"
      add_meta property: "og:title", content: app_title
      add_meta property: "og:description", content: app_desc
      add_meta property: "og:image", content: @image if @image
      add_meta property: "article:author", content: author || Ha2itat.C(:author)

      add_meta property: "twitter:card",   content: "summary_large_image"
      add_meta property: "twitter:domain", content: Ha2itat.C(:host)
      add_meta property: "twitter:url",    content: app_url if @url
      add_meta property: "twitter:title",  content: app_title
      add_meta property: "twitter:description", content: app_desc
      add_meta property: "twitter:image",  content: @image if @image
    }

    def self.title_seperator=(obj)
      @title_seperator = obj
    end

    def self.title_seperator
      @title_seperator || " — "
    end

    def routes
      Hanami.app["routes"]
    end

    def initialize(view, request, **kwargs)
      @elements = []
      @view = view
      kwargs.each_pair do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end


    # Ha2itat::Meta.customize do
    #   add_meta kekelala: "youmom"
    # end
    def self.customize(&blk)
      @customized = blk
    end

    def self.customized
      @customized
    end

    def color_scheme
      @color_scheme || "dark light"
    end

    def add_meta(**kwargs)
      keyword_string = kwargs.inject("") do |m, pair|
        m << '%s="%s" ' % pair
      end
      elements << "<meta #{keyword_string}>"
    end

    def add_link(**kwargs)
      keyword_string = kwargs.inject("") do |m, pair|
        m << '%s="%s" ' % pair
      end
      elements << "<link #{keyword_string}>"
    end

    def add_title(stitle)
      elements << "<title>%s</title>" % stitle
    end

    def with_social_media
      instance_eval(&SOCIAL_MEDIA)
      self
    end

    def to_head
      instance_eval(&DEFAULTS)
      instance_eval(&self.class.customized) if self.class.customized
      "\n%s\n" % [elements.join("\n")]
    end

    def app_title
      cfgtitle = Ha2itat.C(:title) || "[default-title]"
      if @title
        "%s%s%s" % [@title, Meta.title_seperator, cfgtitle]
      else
        cfgtitle
      end
    end

    def app_url
      if @url.to_s =~ /^http/
        @url
      else
        ::File.join(Ha2itat.C(:host), @url)
      end
    rescue
      @url
    end

    def title
      app_title
    end

    def desc
      app_desc
    end

    def app_desc
      @desc || Ha2itat.C(:desc) || "[default-desc]"
    end

  end
end
