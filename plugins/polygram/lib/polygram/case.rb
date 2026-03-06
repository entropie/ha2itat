module Plugins
  module Polygram

    class Cases < Array
    end

    class Case

      class CaseVariables < Hash
        def merge_from_input(**param_hash)
          user = param_hash.delete(:user)
          user ||= Ha2itat.adapter(:user).by_id(param_hash.delete(:user_id))

          self.merge(user_id: user.id).merge(**param_hash)
        end
      end

      class CaseMedia < Array
        class CaseMediaEntry
          attr_reader :file, :case
          def initialize(file, caze)
            @file = file
            @case = caze
          end

          def mid
            basename.split(".").first
          end

          alias :id :mid

          def path
            file
          end

          def url
            @case.http_path("polygram", @case.id, basename)
          end

          def basename
            ::File.basename(@file)
          end

          def title(l = 8)
            mid[0..l-1]
          end

          def =~(idormedia)
            id = idormedia
            if idormedia.kind_of?(CaseMediaEntry)
              id = idormedia.id
            end
            self.id == id
          end

          def exist?
            ::File.exist?(@file)
          end

          def annotations_by_user
            @case.by_contributor.each_pair do |uid, datahash|
              annotations = datahash[id]
              next unless annotations
              observations = annotations.select{ |a| a.observation? }.shift
              readings = annotations.select{ |a| not a.observation? }.shift

              yield Ha2itat.adapter(:user).by_id(uid), self, observations, readings
            end
          end
        end

        class Video < CaseMediaEntry
          def kind; :video; end
        end

        class Image < CaseMediaEntry
          def kind; :image; end
        end

        def self.read_for(caze)
          ret = Ha2itat.adapter(:polygram).media_files(caze).map{ |file|
            Video.new(file, caze)
          }
          CaseMedia.new(ret)
        end

        def [](mid)
          select{ |cme| cme.mid == mid }.shift
        end
      end

      attr_accessor :id, :variables, :public, :kind, :path

      module ForceSymbolHash
        def clean(target = Hash)
          old = self
          new = target.new

          old.each_pair { |k,v| new.store(k.to_sym, v) }
          new
        end
      end
      
      def self.from_json(json)
        ret = new
        [:id, :path, :public, :kind].each do |attr|
          ret.send("#{attr}=", json[attr.to_s])
        end
        ret.variables = json["variables"].extend(ForceSymbolHash).clean(CaseVariables)
        ret
      end

      def initialize(**param_hash)
      end

      def setup(**param_hash)
        @variables = CaseVariables.new.merge_from_input(**param_hash)
        @id = Ha2itat::Database.get_random_id
        @public = false
        self
      end

      def adapter
        @adapter ||= Ha2itat.adapter(:polygram)
      end

      def path(*args)
        adapter.case_path(id, *args)
      end

      def http_path(*args)
        ::File.join("/", *args)
      end

      def user
        Ha2itat.adapter(:user).by_id(variables[:user_id])
      end

      def title(length = 8)
        "case <code>%s</code>" % id[0..length-1]
      end

      def css_class
        type_class = kind == "videos" ? "video-case" : "image-case"
        "%s %s" % [public ? "case public-case" : "case private-case", type_class]
      end

      # return:
      #     { 'USERID':
      #         'MEDIAID': [
      #           [ reading, observation ]
      #         ],
      #         ..
      #       ...
      #     }
      def by_contributor
        user = {}
        [
          Ha2itat.adapter(:polygram).readings_for(self),
          Ha2itat.adapter(:polygram).observations_for(self)
        ].flatten.each do |rooentry|
          user[rooentry.user.id] ||= {  }
          user[rooentry.user.id][rooentry.mid] ||= []
          user[rooentry.user.id][rooentry.mid] << rooentry
        end
        user
      end

      def observed_by?(userid, mid)
        by_contributor[userid][mid].any?{ |obsorreading| obsorreading.class == Case::Observation } rescue false
      end

      def read_by?(userid, mid)
        by_contributor[userid][mid].any?{ |obsorreading| obsorreading.class == Case::Reading } rescue false
      end

      def exist?
        File.exist?(path)
      end

      def relative_path(*args)
        base_path = "cases/%s" % id
        File.join(base_path, *args)
      end

      def media(idmaybe = nil, force: false)
        res = CaseMedia.read_for(self)
        if idmaybe
          return res.select{ |cm| cm =~ idmaybe }.shift
        end
        res
      end

      def metadata
        {
          id: id,
          path: relative_path,
          public: public,
          kind: kind,
          variables: variables
        }
      end

      def metadata_file
        relative_path("metadata.json")
      end

      def storage_path(*args)
        adapter.repository_path("polygram/%s" % id, *args)
      end

      def relative_storage_path(*args)
        ::File.join("polygram/%s" % id, *args)
      end
    end

    class VideosCase < Case
      def kind
        :videos
      end
    end

    class ImagesCase < Case
      def kind
        :images
      end
    end

  end
end

