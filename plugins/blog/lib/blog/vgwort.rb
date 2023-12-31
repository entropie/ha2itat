module Plugins

  module Blog

    module VGWort

      class VGWortFilter < Blog::Filter
        def vgwort_counter
          post_with_vgwort = post.extend(Plugins::Blog::VGWort)
          if Ha2itat.quart.development?
            "<div class='vgwort-counter visible'>vgwort:%s</div>" % post_with_vgwort.vgwort.refid
          else
            "<div class='vgwort-counter'>#{post_with_vgwort.vgwort.counter}</div>"
          end
        end

        def filter(str)
          str + vgwort_counter
        end
      end


      VGWortEntry = Struct.new(:index, :code, :id, :url, :slug) do
        def to_s
          [index, code, id, url, slug].join(";")
        end

        def free?
          slug and slug.to_s.empty?
        end
      end

      def self.initialize
        if Ha2itat.quart and mp = Ha2itat.quart.media_path("vgwort.csv")
          if File.exist?(mp)
            csv = File.readlines(mp).join
            read_csvstr_to_database(csv)
            create_database
            Ha2itat.log "vgwort init done"
          end
        end
      end

      def self.initialized?
        [Ha2itat.quart.media_path("vgwort.csv"),
         Ha2itat.quart.media_path(".vgwortdb")].map{|vgwfile|
          ::File.exist?(vgwfile)
        }.all?
      end

      def self.database=(obj)
        @database = obj
      end

      def self.database_path
        (Ha2itat.quart && Ha2itat.quart.media_path) || TMP_PATH
      end

      def self.database
        unless @database
          target_path = database_path

          file = File.join(target_path, ".vgwortdb")
          if File.exist?(file)
            @database = File.readlines(file).map{|line|
              VGWortEntry.new(*line.split(";").map(&:strip))
            }
          end
        end

        unless @database
        end

        @database
      end

      def self.read_csvstr_to_database(str)
        code = nil
        cur = nil
        ret = []
        str.strip.each_line do |line|
          line = line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
          if line =~ /^\d+/
            nr, link, _ = line.split(";")
            url = URI.extract(link).first
            id = url.split("/").last
            cur = VGWortEntry.new(nr.to_i, code, id, url)
          elsif line =~ /Identifikationscode/
            cur.code = line.strip.split(";").last.to_s
            ret << cur
          end
        end
        self.database = ret
      end

      def self.create_database
        dir = database_path
        file = File.join(dir, ".vgwortdb")
        raise "#{file} existing; nope" if File.exist?(file)
        raise "database not seeded; nope" unless database

        File.open(file, "w+") {|fp|
          database.each do |dbentry|
            fp.puts dbentry.to_s
          end
        }
      end

      def self.update_database
        dir = database_path
        file = File.join(dir, ".vgwortdb")
        Ha2itat.log "vgwort: update"
        File.open(file, "w+") {|fp|
          database.each do |dbentry|
            fp.puts dbentry.to_s
          end
        }

      end

      def self.fetch_for(post, &blk)
        ret = false
        database.each do |dbentry|
          if dbentry.free?
            ret = yield dbentry.index, dbentry.code, dbentry.id, dbentry.url
            if ret
              dbentry.slug = post.slug
              update_database
              return true
            end
          end
        end
        Ha2itat.log "no free entry in database found"
      end


      def self.extended(mod)
      end

      def vgwort
        VGWort.new(self)
      end

      def id_attached?
        vgwort.id_attached?
      end

      def attach_id
        unless id_attached?
          Plugins::Blog::VGWort.fetch_for(self) do |index, code, id, url|
            Ha2itat.log "VGWORT: post: #{slug}: attaching ##{index} #{code}:#{id}"
            Ha2itat.log "VGWORT: post: #{slug}: written #{vgwort.file}"
            vgwort.write(url, id)
            true
          end
        else
          Ha2itat.log "VGWORT: post: #{slug}: already id attached"
        end
      end

      class VGWort

        attr_reader :post


        def initialize(post)
          @post = post
        end

        def file
          post.datapath(".vgwort")
        end

        def id_attached?
          File.exist?(file)
        end

        def contents
          @contents ||=
            if File.exist?(file)
              File.readlines(file)
            else
              []
            end

          if Ha2itat.C(:host) and Ha2itat.C(:host) =~ /^https\:/ and not @contents.empty?
            @contents.first.gsub!(/http/, "https")
            @contents.first.gsub!(/(vg[0-9]+)\./, "ssl-vg03.")
          end

          @contents
        end

        def counter
          if id_attached?
            @counter = contents.first
          else
            Ha2itat.warn "vgwort counter for #{post.slug} not attached"
            ""
          end
        end


        def refid
          @code ||= contents.last.strip
        rescue
          ""
        end

        def write(url, id)
          img = "<img src='%s' alt='' />" % url

          str = [img, id].join("\n")

          File.open(file, "w+") {|fp|
            fp.puts str
          }
          self
        end

      end
    end
  end
end
