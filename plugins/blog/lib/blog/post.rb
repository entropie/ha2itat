# coding: utf-8

module Plugins

  module Blog

    module I18N

      TRANSLATIONS = {
        en: "This post was originally written in german titled <strong>%title%</strong>, <a href='%url%'>but is also in available english</a>.",
        de: "Dieser Beitrag wurde usprünglich auf Deutsch verfasst und befindet sich hier: <a href='%url%'>%title%</a>."
      }

      def request_language=(obj)
        @request_language = obj
      end

      def request_language
        @request_language
      end

      def self.valid_language(lstr)
        TRANSLATIONS.keys.include?(lstr.to_sym)
      end

      def native?
        if @request_language
          return false
        end
        true
      end

      def i18n(langstr)
        return false unless langstr
        if Blog::I18N.valid_language(langstr)
          self.request_language = langstr
        end
      end

      def languages(l = nil)
        re = /^content\-([a-zA-Z]{2})\./
        ret = Dir.entries(datapath).select{|e| e =~ re}.map{|file| file =~ re && $1}
        if l
          return ret.include?(l)
        end
        ret
      rescue
        []
      end

      def language
        request_language ? request_language : nil
      end

      def alternatives?
        languages.size > 0
      end

      def alternatives
        ret = []
        replacer = -> (l) {
          lang = !native? ? :de : l.to_sym
          str = TRANSLATIONS[lang]
          str.gsub!(/%title%/, title)
          u = native? ? url(l.to_sym) : url
          str.gsub!(/%url%/, u)
          str
        }

        languages.each {|lang|
          ret << replacer.call(lang)
        }
        ret.join
      end

      def datafile
        datafileident = "content%s" % (@request_language ? "-#{@request_language}" : "")
        datapath("#{datafileident}.markdown")
      end
    end


    class Post

      include I18N

      Attributes = {
        :content     => String,
        :title       => String,
        :created_at  => Time,
        :updated_at  => Time,
        :tags        => Array,
        :image       => Image,
        :template    => String,
        :user_id     => String
      }

      OptionalAttributes = [:image, :template]

      attr_reader :image, :adapter, *Attributes.keys

      attr_accessor :filename, :datadir, :user_id, :created_at, :updated_at

      def self.make_slug(str) #
        #str.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        ::Ha2itat::Database::make_slug(str)
      end

      def backend_display_information
        bdi = [
          [:created, to_human],
          [:tags, tags.join(", ")],
        ]
        bdi
      end


      def initialize(adapter)
        @adapter = adapter
      end

      def populate(param_hash)
        if param_hash[:tags]
          if param_hash[:tags].kind_of?(String)
            param_hash[:tags] = param_hash[:tags].split(",").map{|t| t.to_s.strip }
          end
        end

        param_hash.each do |paramkey, paramval|
          instance_variable_set("@#{paramkey}", paramval)
        end
        self
      end

      def upload(obj)
        img = Image.new(obj.path) rescue Image.new(obj)
        img.copy_to(self)
        @image = img
      end

      def http_data_dir(*args)
        File.join("/attachments", slug, *args)
      end

      def app_route()
        Hanami.app["routes"].path(:post, slug: slug)
      rescue
        "/post/#{slug}"
      end

      def to_hash
        rethash = {  }
        rethash[:content]    = with_filter
        rethash[:intro]      = intro
        rethash[:user]       = Ha2itat.adapter(:user).by_id(user_id).name
        rethash[:created_at] = created_at
        rethash[:updated_at] = updated_at
        rethash[:title]      = title
        rethash[:url]        = app_route
        rethash[:slug]       = slug
        rethash[:image]      = image.url rescue ""
        rethash[:tags]       = tags
        rethash
      end

      def to_h
        rethash = {  }
        rethash[:content]    = content
        rethash[:user_id]    = Ha2itat.adapter(:user).by_id(user_id).id
        rethash[:created_at] = created_at
        rethash[:updated_at] = updated_at
        rethash[:title]      = title
        rethash[:url]        = app_route
        rethash[:slug]       = slug
        rethash[:image]      = image if image
        rethash[:tags]       = tags
        rethash
      end

      def update(param_hash)
        populate(param_hash)
        self
      end

      def slug
        @slug ||= Post.make_slug(title)
      end

      def id
        slug
      end

      def content
        @content ||= if File.exist?(datafile)
                       File.readlines(datafile).join
                     else
                       "[could not read datafile]"
                     end
      end

      def dirname
        "posts"
      end

      def to_filename
        "#{slug}#{Blog::Database::Adapter::File::BLOGPOST_EXTENSION}"
      end

      def filename
        @filename = ::File.join(dirname, to_filename)
      end

      def fullpath(*args)
        adapter.repository_path(filename)
      end

      def datadir(*args)
        @datadir = adapter.datadir(slug, *args)
      end

      def datapath(*args)
        adapter.path( datadir(*args) )
      end

      def relative_datapath(*args)
        adapter.datadir(*args)
      end

      def intro
        if content.include?("\r\n")
          content.split("\r\n\r\n").first
        else
          content.split("\n\n").first
        end
      end

      def adapter
        @adapter || Ha2itat.adapter(:blog)
      end

      def images
        Dir.glob(datapath("image") + "/*.*").map {|ipath| Image.from_datadir(self, ipath) }
      end

      def image
        return nil unless @image
        @image.post = self
        @image
      rescue
        nil
      end

      def template
        @template
      end

      def with_template(t = template)
        templ = (t || template).to_sym
        Blog.templates(Blog.template_path)[templ].apply(self)
      end

      def for_yaml
        ret = dup
        begin
          [:adapter, :content, :request_language, :lang].map{|iv| "@#{iv}"}.each do |iv|
            ret.remove_instance_variable(iv) if ret.instance_variable_get(iv)
          end
          #rescue
        end
        if image
          image.remove_instance_variable("@post")
        end

        ret
      end

      def url(variant = nil)
        if variant
        else
          Hanami.app["routes"].path(:post, slug: slug)
        end
      rescue
        "/post/#{slug}"
      end

      def draft?
        false
      end

      def valid?
        missing = []
        Attributes.each do |attribute, attribute_type|
          next if OptionalAttributes.include?(attribute)
          if not var = instance_variable_get("@#{attribute}")
            missing << attribute
          elsif not var.kind_of?(attribute_type)
            missing << attribute
          else # pass
          end
        end
        not missing.any?
      end

      def to_draft(adapter)
        Draft.new(adapter).populate(to_h)
      end

      # returns [ "Saturday", "May", 12 ]
      def to_calendar_ico
        created_at.strftime("%A;%B;%d").split(";")
      end

      def with_filter
        Filter.new(self).apply
      end

      def with_plugin(pluginmod)
        self.extend(pluginmod)
      end

      def html
        Filter.new(self).apply(Filter::Nokogiri)
      end

      def css_class
        draft? ? "post-draft" : "post"
      end

      def date
        updated_at
      end

      def to_human
        created_at.to_human
      end

      def intro_html
        html = Ha2itat::Renderer.render(:markdown, intro)
        t=Nokogiri::HTML(html)
        html = t.xpath("//text()").remove.to_html
        html.gsub!(/\[\^[0-9]+\]/, "")
        html
      end

      def try_vgwort_attach
        if VGWort.initialized?
          post_with_vgw = self.extend(VGWort)
          if post_with_vgw.id_attached?
            Ha2itat.log("try_vgwort_attach: already attached to `#{slug}'")
          else
            post_with_vgw.attach_id
            Ha2itat.log("try_vgwort_attach: attached id #{post_with_vgw.vgwort.refid}`#{slug}'")
          end
        end
      end

      def user
        Ha2itat.adapter(:user).by_id(user_id)
      end

    end

    class Draft < Post

      def initialize(adapter)
        super(adapter)
        @updated_at = @created_at = Time.now
      end

      def dirname
        "drafts"
      end

      def to_post(adapter)
        Post.new(adapter).populate(to_h)
      end

      def draft?
        true
      end

    end


    class Posts < Array

      attr_reader :user

      def initialize(usr = nil)
        @user = usr
      end

    end

    class Groups < Hash
    end

    class Group < Posts
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def name_sanitized
        @name
      end

      def size(logged_in = false)
        posts(logged_in).size
      end
    end

  end
end
