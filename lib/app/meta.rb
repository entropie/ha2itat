module Ha2itat
  class Meta

    attr_reader :title, :desc, :image, :type, :author

    attr_accessor :elements
    
    DEFAULTS = proc {
      add_meta charset: "utf-8"
      add_meta name:    "viewport", content: "width=device-width, initial-scale=1"

      add_meta name:    "title", content: app_title
      add_meta name:    "description", content: app_desc
      add_title app_title
    }

    SOCIAL_MEDIA = proc {
      add_meta property: "og:type", content: type || "website"
      add_meta property: "og:title", content: app_title
      add_meta property: "og:description", content: app_desc
      add_meta property: "og:image", content: @image if @image
      add_meta property: "article:author", content: author || Ha2itat.C(:author)
    }
    
    def self.title_seperator=(obj)
      @title_seperator = obj
    end

    def self.title_seperator
      @title_seperator || "&mdash;"
    end

    def initialize(view, **kwargs)
      @elements = []

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

    def add_meta(**kwargs)
      keyword_string = kwargs.inject("") do |m, pair|
        m << '%s="%s" ' % pair
      end
      elements << "<meta #{keyword_string}/>"
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

      elements.join
    end

    def app_title
      cfgtitle = Ha2itat.C(:title) || "[default-title]"
      if @title
        "%s%s%s" % [@title, Meta.title_seperator, cfgtitle]
      else
        cfgtitle
      end
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
