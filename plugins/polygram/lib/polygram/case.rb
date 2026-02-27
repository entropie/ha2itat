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
            @case.http_path("storage", basename)
          end

          def basename
            ::File.basename(@file)
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

      def self.from_json(json)
        ret = new
        [:id, :path, :public, :kind, :variables].each do |attr|
          ret.send("#{attr}=", json[attr.to_s])
        end
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
        "/polygram/%s" % relative_path(*args)
      end

      def user
        Ha2itat.adapter(:user).by_id(variables[:user_id])
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

      def exist?
        File.exist?(path)
      end

      def relative_path(*args)
        base_path = "cases/%s" % id
        File.join(base_path, *args)
      end

      def media
        CaseMedia.read_for(self)
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
        path("storage", *args)
      end

      def relative_storage_path(*args)
        relative_path("storage", *args)
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

