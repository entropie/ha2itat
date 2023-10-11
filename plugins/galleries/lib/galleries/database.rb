module Plugins

  module Galleries

    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    module Database

      extend Ha2itat::Database

      class Adapter

        class File < Ha2itat::Database::Adapter

          attr_reader :path

          def initialize(path)
            @path = path
            @user = nil
          end

          def repository_path(*args)
            ::File.join(::File.realpath(path), "public/galleries", *args)
          end

          def find_or_create(gallery_ident, user = nil)
            gallery = Gallery.new(gallery_ident)
            gallery.adapter = self
            gallery.user = user
            gallery
          end

          def find(gallery_ident, user = nil)
            gal = find_or_create(gallery_ident, user)
            raise "gallery not found #{gallery_ident}" unless gal
            gal
          end

          def all(user = nil)
            Dir.glob("%s/*/metadata.yaml" % repository_path).map do |md|
              find_or_create(md.split("/")[-2], user)
            end
          end

          def transaction(gallery, &blk)
            log :info, "gallery:#{gallery.ident} transaction starting..."
            g = yield gallery if block_given?
            gallery.write_metadata
            log :info, "gallery:#{gallery.ident} transaction finish"
            g
          end

        end

      end

    end

  end
end
