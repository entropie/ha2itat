require "open-uri"
require "youtube-dl"

module Plugins
  module Tumblog
    class Post
      class Handler

        attr_reader :post

        def self.handler
          @@handler ||= []
        end

        def self.inherited(o)
          handler << o
        end

        def self.select_for(post)
          ret = handler.select{|h|
            next if h == DefaultHandler
            h.responsible_for?(post)
          }

          # pp ret
          # raise "multiple handler for #{post} found; cannot continue" if ret.size > 1
          handler = ret.last
          handler = DefaultHandler unless handler

          Ha2itat.log("tumblog: (#{handler}:'#{post.content}')")
          handled = handler.new(post)
          handled
        end

        def self.responsible_for?(post)
          match.any?{|r| post.content =~ r}
        end

        def initialize(post)
          @post = post
        end

        def download(url, target)
          ret = nil
          Ha2itat.debug "DL: #{url} -> #{target}"
          open(url){|v|
            File.open(target, "wb") {|fp|
              ret = fp.write(v.read)
              Ha2itat.debug "DL: wrote #{ret}"
            }
          }
          ret
        end

        def thumbnail
          thumbnail_src
        end

        def thumbnail?
          File.exist?(thumbnail_file)
        end

        def thumbnail_file
          post.datadir("#{post.id}.png")
        end

        def thumbnail_src
          post.http_data_dir("#{post.id}.png")
        end

        def target_media_file(filename)
          post.datadir(filename)
        end

        def title
          if post.title and not post.title.to_s.strip.empty?
            post.title
          else
            "&nbsp;"
          end
        end

        def admin_links_hash
          {
            id: post.id,
            "privacy-toggle-url": Hanami.app["routes"].path(:backend_tumblog_toggleprivate, id: post.id),
            "edit-url": Hanami.app["routes"].path(:backend_tumblog_edit, id: post.id),
            "delete-url": Hanami.app["routes"].path(:backend_tumblog_destroy, id: post.id)
          }
        end

        def to_html(logged_in = false)
          add = ""
          if logged_in
            add = admin_links_hash.to_a.inject(""){|str, pair|
              str<< " data-%s='%s'" % pair
            }
          end
          ret = "<video#{add} controls style=''><source src='%s' type='video/mp4'></video>"
          ret
        end

        def self.match
          [false]
        end

        def process!
          true
        end

        def create_interactive?
          false
        end


        module ResponseCode

          def http_response_code(uri)
            response = Net::HTTP.get_response(URI(uri))
            response.code.to_i
          rescue
            return 301 # moved permanently
          end

          def responding?(to = 200)
            url = URI.extract(post.content).shift.to_s
            http_response_code(url) == to
          end

        end


        module YoutubeDLMixin
          def media_file
            Dir.glob("%s/*.*" % [post.real_datadir]).first
          end

          def media_file_src
            post.http_data_dir(File.basename(media_file))
          end
        end

        class DefaultHandler < Handler

          def create_interactive?
            true
          end

          def to_html(logged_in = false)
            Ha2itat::Renderer.render(:markdown, post.content)
          end

        end

        class Reddit < Handler

          include YoutubeDLMixin
          include ResponseCode

          include Ha2itat::Mixins::FU

          def self.match
            [/^https:\/\/reddit\.com/, /^https:\/\/www\.reddit\.com/, /^https:\/\/v\.redd\.it\//]
          end

          def process!
            FileUtils.mkdir_p(post.datadir)

            # use client side yt-dlp implementation if blocked of forced by config
            if not responding?(302) or Ha2itat::C(:clytdlp)
              raise Plugins::Tumblog::SkipForYTDLPClientVersion.new("reddit blocked (probably subnetwide)")
            end

            target_file = target_media_file(post.id+".mp4")

            if ::File.exist?(target_file)
              rm(target_file)
            end

            log "ytdl: #{post.id} #{post.content} #{target_file}"

            ydl = YoutubeDL.download(post.content, output: target_file, write_thumbnail: true)
            post.title = ydl.information[:title]
            true
          end

          def to_html(logged_in = false)
            super % post.http_data_dir(post.id + ".mp4")
          end
        end

        class Youtube < Handler
          include YoutubeDLMixin

          def self.match
            [/^https:\/\/youtube\.com/, /^https:\/\/www\.youtube\.com/]
          end

          def process!
            FileUtils.mkdir_p(post.datadir)

            target_file = target_media_file(post.id+".mp4")
            ydl = YoutubeDL.download(post.content, output: target_file)
            post.title = ydl.information[:title]
            true
          end

          def to_html(logged_in = false)
            add = "<h3>#{post.title}</h3>"
            ret = "%s<video controls><source src='%s' type='video/mp4'></video>"
            ret % [add, media_file_src]
          end
        end

        class Gifv < Handler
          def self.match
            [/\.gifv$/i]
          end

          def process!
            FileUtils.mkdir_p(post.datadir)

            target_file = post.datadir(post.id + ".mp4")

            ydl = YoutubeDL.download(post.content, output: target_file)
            true
          end


          def to_html(logged_in = false)
            super % post.http_data_dir(post.id + ".mp4")
          end

        end


        class Img < Handler
          attr_accessor :extension

          def self.match
            @match ||= [:gif, :jpg, :png, :gif, :tiff, :webp].map{|type|
              /#{type}$/
            }
          end

          def parsed_url(str)
            str.strip
          end

          def extension
            @extension ||= parsed_url(post.content).split(".").last
          end

          def thumbnail_file
            post.datadir("#{post.id}.#{extension}")
          end

          def thumbnail_src
            post.http_data_dir("#{post.id}.#{extension}")
          end

          def download(url, path)
            case io = URI.open(url)
            when StringIO then File.open(path, 'w') { |f| f.write(io.read) }
            when Tempfile then io.close; ::FileUtils.mv(io.path, path)
            end
          end

          def request_result(uristr)
            URI.open(uristr).read
          end


          include Ha2itat::Mixins::FU

          def process!

            FileUtils.mkdir_p(post.datadir)
            purl = parsed_url(post.content)
            @extension = purl.split(".").last
            if purl =~ /reddit\.com/
              uuri = URI(purl)
              purl =  parsed_url(CGI.unescape(uuri.query.split("=").last))
              Ha2itat.log("reddit image; using uri from query #{purl}")
            end
            download(purl, thumbnail_file)
            true
          end

          def to_html(logged_in = false)
            add = ""
            if logged_in
              add = admin_links_hash.to_a.inject(""){|str, pair|
                str<< " data-%s='%s'" % pair
              }
            end
            "<img #{add} src='%s' alt='#{post.title || ""}'>" % [thumbnail_src]
          end

        end
      end


      Attributes = {
        :content     => String,
        :title       => String,
        :created_at  => Time,
        :id          => String,
        :updated_at  => Time,
        :tags        => Array,
        :user_id     => Integer,
        :private     => Integer
      }

      attr_reader *Attributes.keys
      attr_accessor :user_id, :datadir, :filename, :title, :private, :updated_at

      def initialize(a)
        @adapter = a
        @private = 0
      end

      def populate(param_hash)
        param_hash.each do |paramkey, paramval|
          if paramval.class != Attributes[paramkey]
            Ha2itat.log "wrong type;expected:#{Attributes[paramkey]}: #{paramkey}:'#{paramval}'"
          end
          instance_variable_set("@#{paramkey}", paramval)
        end
        @tags = [] unless @tags
        @updated_at = @created_at = Time.now
        @id = Ha2itat::Database.get_random_id
        self
      end

      def update(hash)
        changed = false

        if new_tags = hash[:tags]
          @tags = Tumblog.tagify(new_tags)
        end

        if new_title = hash[:title]
          @title = new_title
        end

        new_content = hash[:content]

        if new_content && new_content != self.content
          changed = true
          @content = hash[:content]
        end

        @updated_at = Time.now if changed
        changed
      end

      def to_hash
        Attributes.keys.inject({}) {|m, k|
          m[k] = instance_variable_get("@%s" % k.to_s)
          m
        }
      end

      def private?
        @private == 1
      end

      def private!
        @private = 1
      end

      def titled?
        @title && @title.to_s.strip.size > 1
      end

      def to_yaml
        r = self.dup
        r.remove_instance_variable("@adapter") if @adapter
        r.remove_instance_variable("@handler") if @handler
        YAML::dump(r)
      end

      def http_data_dir(*args)
        File.join("/_tumblog/data/", user_id, id, *args)
      end

      def datadir(*args)
        adapter.datadir(adapter.user.id, id, *args)
      end

      def real_datadir(*args)
        datadir(*args)
      end

      def relative_datadir(*args)
        ::File.join("public/data/tumblog", user.id, id, *args)
      end

      def to_filename
        "#{id}#{Tumblog::Database::Adapter::File::TUMBLPOST_EXTENSION}"
      end

      def filename
        @filename || ::File.join(dirname, to_filename)
      end

      def file
        adapter.repository_path(filename)
      end

      def path
        adapter.repository_path(dirname)
      end

      def adapter
        @adapter ||= Ha2itat.adapter(:tumblog)
      end

      def relative_filename
        filename
      end

      def exist?
        true
      end

      def dirname
        "entries/#{@created_at.strftime("%Y%m")}"
      end

      def handler
        if @force_handler
          @handler = Handler::DefaultHandler.new(self)
        end
        @handler ||= Handler.select_for(self)
      end

      def default_handler
        @force_handler = :default
        @handler = Handler::DefaultHandler.new(self)
      end

      def thumbnail
        handler.thumbnail

      end

      def to_html(logged_in = false)
        handler.to_html(logged_in)
      end

      def css_class
        visible_add = @private == 1 ? " private" : ""
        "tumblpost-entry #{kind} #{visible_add}"
      end

      def css_id
        "entry-#{id[0..10]}"
      end

      def slug
        @slug || id
      end

      def kind
        handler.class.to_s.downcase.split("::").last.to_sym
      end

    end

    class Entries < Array
      attr_reader :user
      def initialize(user)
        @user = user
      end
    end

  end
end
