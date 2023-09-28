module Plugins

  module Galleries

    module GalleriesAccessMethods

      def CSS_BACKGROUND(gal, ident)
        gallery = Ha2itat.adapter(:galleries).find(gal)
        img = gallery.images(ident)

        msg = ""
        if !gallery
          msg = "gallery <i>#{gal}</i> not existing"
        elsif !img
          msg = "image <i>#{ident}</i> not existing in gallery <i>#{gal}</i>."
        else
          begin
            return _raw(img.css_background_defintion)
          rescue
            return img.css_background_defintion
          end
        end
      end
      

      def IMGSRC(gal, ident)
        gallery = Ha2itat.adapter(:galleries).find(gal)
        img = gallery.images(ident)

        msg = ""
        if !gallery
          msg = "gallery <i>#{gal}</i> not existing"
        elsif !img
          msg = "image <i>#{ident}</i> not existing in gallery <i>#{gal}</i>."
        else
          begin
            return _raw(img.url)
          rescue
            return img.url
          end
        end

        return "<div class='error-msg'>#{msg}</div>"
      end

      def IMG(gal, ident, hsh = {  })
        gal = gal.to_s
        ident = ident.to_s
        gallery = Ha2itat.adapter(:galleries).find(gal)
        img = gallery.images(ident)

        msg = ""
        if !gallery
          msg = "gallery <i>#{gal}</i> not existing"
        elsif !img
          msg = "image <i>#{ident}</i> not existing in gallery <i>#{gal}</i>."
        else
          acss = hsh.map{ |h,k| "#{h}:#{k}" }.join(";")
          return "<div id='#{img.dom_id}' href='#{img.url}' class='galleries-image popup-img' style='background-image: url(#{img.url});#{acss}'></div>"
        end

        return "<div class='error-msg'>#{msg}</div>"
      end

      # def SliderGallery(name, except: [], only: [], &blk)
      #   gallery = Ha2itat.adapter(:galleries).find(name.to_s)
      #   gallery = gallery.extend(GalleryPresenter)


      #   # if there is only a single image in gallery, we dont need to show the entire gallery
      #   # but the single img (dispatch to #IMG)
      #   if (imgs = gallery.select_images(except, only)).size == 1
      #     return IMG(name.to_s, imgs.first.hash)
      #   end

      #   gallery.to_slider(except: except, only: only, images: imgs)
      # rescue Ha2itat::Database::EntryNotValid
      #   return "<div class='error-msg'>Gallery: <i>#{name}</i> not existing</div>."
      # end

    end


    DEFAULT_ADAPTER = :File

    class Galleries < Array
    end

    def log(a)
      Ha2itat.log(a)
    end

    class Metadata < Hash
      def initialize
      end

      def add_image(image)
        self[:images].merge!(image.hash => image)
        self
      end

      def remove_image(image)
        self[:images] = self[:images].dup.delete_if{|h, img| img == image }
        self
      end

      def images
        self[:images]
      end

      def self.create(gallery)
        Metadata.new.
          merge(
            :name => gallery.ident,
            :images => {}
          )
      end
    end


    class Gallery
      include Plugins::Galleries

      class Image
        attr_reader :filename
        attr_reader :gallery

        def initialize(filename, gallery)
          @filename = filename
        end

        def hash
          @hash ||= File.basename(filename).split(".").first
        end

        def delete
          FileUtils.rm_rf(path, :verbose => true)
        end

        def gallery
          Ha2itat.adapter(:galleries).find(@filename.split("/").first)
        end
        
        def path
          Ha2itat.adapter(:galleries).repository_path(@filename)
        end

        def size
          ::File.size(path)
        end

        def human_size
          '%.2f' % (size.to_f / 2**20)
        end

        def fullpath
          path
        end

        def self.hash_filename(file)
          ret = Digest::SHA1.hexdigest(File.new(file).read) + File.extname(file).downcase
        end

        def http_path(*args)
          Hanami.app["routes"].path(:image, path: ::File.join(filename))
        end
        
        def url
          http_path
        end

        def css_background_defintion
          "background-image: url(%s)" % url
        end
        
        def ident
          @ident || hash
        end

        def ident=(obj)
          @ident = obj.to_s
        end

        def dom_id
          "gallery-%s-%s" % [gallery.ident, ident]
        end

        def ==(obj)
          if obj.kind_of?(Image)
            self == obj.hash
          else
            ident == obj or @hash == obj
          end
        end
      end


      attr_reader :ident
      attr_accessor :adapter
      attr_accessor :user
      attr_reader :metadata

      def file_exist?(f)
        File.exist?(path(f))
      end

      def exist?
        File.exist?(path)
      end


      def initialize(ident)
        @ident = ident
      end

      def metadata
        return @metadata if @metadata
        if file_exist?("metadata.yaml")
          permitted_classes = [Plugins::Galleries::Metadata, Plugins::Galleries::Gallery::Image, Symbol]
          @metadata = YAML::load_file(path("metadata.yaml"), permitted_classes: permitted_classes)
        else
          @metadata = Metadata.create(self)
        end
        @metadata
      end

      def write_metadata
        file = path("metadata.yaml")
        FileUtils.mkdir_p(path, :verbose => true)

        metadata
        File.open(file, "w+") do |fp|
          fp.puts(YAML::dump(metadata))
        end

        log "gallery:#{ident}: writing #{file}"
      end


      def rpath(*args)
        File.join(ident, *args)
      end
      
      def path(*args)
        adapter.repository_path(ident, *args)
      end

      def filename
        path("gallery.yaml")
      end

      def images(imgh = nil)
        if metadata[:images]
          ims = metadata[:images].values
          if imgh
            single_image = ims.select{|i| i == imgh}.first
            if single_image
              return single_image
            end
          else
            ims
          end
        else
          []
        end
      end

      def set_ident(img, ident)
        if existing_image = images(ident)
          raise Ha2itat::Database::DataBaseError,
                "ident '#{ident}' already set for #{existing_image.hash} : #{existing_image.filename}"
        end
        metadata.images[img.hash].ident = ident
      end

      def add(imagepaths)
        ([imagepaths].flatten).each do |imagepath|
          FileUtils.mkdir_p(path("images"), :verbose => true)
          hashed_filename = Image.hash_filename(imagepath)

          relative_path = rpath("images", hashed_filename)
          
          FileUtils.cp(imagepath, path("images", hashed_filename), :verbose => true)
          log "  gallery:#{ident}: adding: #{imagepath} => #{relative_path}"

          metadata.add_image(Image.new(relative_path, self))
        end
      end

      def remove(img_or_imghash)
        hash = img_or_imghash
        if img_or_imghash.kind_of?(Image)
          hash = img_or_imghash.hash
        end
        img = images(hash)
        metadata.remove_image(img)
        img.delete
        self
      end
      
    end
    
  end
end
