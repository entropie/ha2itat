module Plugins
  module Polygram


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
      end

      attr_reader :user, :id, :variables, :public

      def initialize(**param_hash)
        @variables = CaseVariables.new.merge_from_input(**param_hash)
        @id = Ha2itat::Database.get_random_id
        @public = false
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

      def exist?
        File.exist?(path)
      end

      def relative_path(*args)
        base_path = "cases/%s" % id
        File.join(base_path, *args)
      end

      def media
        @media ||=
          begin
            CaseMedia.read_for(self)
          end
      end

      def metadata
        {
          user_id: variables[:user_id],
          id: id,
          path: relative_path,
          public: public,
          kind: kind,
          media: [media.map{ |m| "%s:%s" % [m.kind, ::File.basename(m.file)] }.join(",")]
        }
      end

      def metadata_file
        relative_path("metadata.yaml")
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

