# coding: utf-8

module Plugins
  
  module Zettel

    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    module Database

      extend Ha2itat::Database

      class Adapter

        class File < Ha2itat::Database::Adapter

          SHEET_EXTENSION = ".sheet.yaml".freeze
          
          include Ha2itat::Mixins::FU

          attr_reader :path

          module SheetFileExtension
            attr_accessor :file
          end

          def initialize(path)
            @path = path
            @user = nil
          end

          def adapter_class
            Sheet.new.extend(SheetFileExtension)
          end

          def path(*args)
            ::File.join(@path, *args)
          end

          def realpath(*args)
            Ha2itat.quart.media_path(*args)
          end

          def user_path(*args)
            ::File.join("zettel", @user.id.to_s, *args)
          end

          def time_to_path(time = Time.now)
            time.strftime("%Y/%m/").split("/")
          end

          def relative_path_for(sheet)
            ::File.join(user_path, sheet.time_to_path, sheet.id)
          end
          
          def directory_for(sheet)
            realpath( relative_path_for(sheet) )
          end

          def relative_filename_for(sheet)
            ::File.join(relative_path_for(sheet), sheet.filename)
          end

          def filename_for(sheet)
            realpath(relative_path_for(sheet), sheet.filename)
          end

          def markdown_file_for(sheet)
            ::File.join(relative_path_for(sheet), "sheet.markdown")
          end

          def metadata_file_for(sheet)
            ::File.join(relative_path_for(sheet), "metadata" + SHEET_EXTENSION)
          end

          def data_dir_for(sheet)
            Ha2itat.quart.media_path(::File.join("public/data/zettel", user.id, sheet.time_to_path, sheet.id))
          end

          def http_data_dir
            ::File.join("public/data/zettel", user.id, sheet.time_to_path, sheet.id)            
          end
          
          def setup
            @setup = true
            log :debug, "setting up adapter directory #{path}"
            mkdir_p(path)
            @setup
          end

          def setup?
            @setup and ::File.exist?(path)
          end

          def with_user(user, &blk)
            @user, @sheets = user, nil

            if block_given?
              ret = yield self
              @user, @sheets = nil, nil
            else
              return self
            end
            ret
          end

          
          def sheet_files(user = nil)
            raise Ha2itat::Database::NoUserContext, "cant read sheets without user" if user.nil? and @user.nil?
            complete_path = realpath(user_path + "/**/**/**/*" + SHEET_EXTENSION)
            Dir.glob(complete_path)
          end


          def by_reference(reference, user = nil, &blk)
            sheets(user, &blk).by_reference(reference)
          end

          def by_reference_sorted(reference, user = nil, &blk)
            sheets(user, &blk).by_reference_sorted(reference)
          end

          def sheets(user = nil, &blk)
            raise Ha2itat::Database::NoUserContext, "cant read sheets without user" if user.nil? and @user.nil?
            read_sheets = []
            sheet_files(user).each do |sfile|
              read_sheets << load_file(sfile)
            end

            ret = Sheets.new(user || @user).push(*read_sheets)
            if block_given?
              ret.each(&blk)
            end
            return ret
          end

          def ordered(user = nil)
            raise Ha2itat::Database::NoUserContext, "cant read sheets without user" if @user.nil?            
            sheets(user || @user).sort_by{|s| s.updated_at}.reverse
          end

          def by_id(sid)
            rethash = find(id: sid)
            rethash.shift || nil # fixme
          end

          def find(phash)
            ret = Sheets.new(@user)
            sheets(@user).each{|s|
              candidate = s
              phash.each do |k,v|
                ret.push(candidate) if candidate.send(k) == v
              end
            }
            ret
          end

          def load_file(sfile)
            YAML.load_file(sfile, permitted_classes: [Plugins::Zettel::Sheet, Time])
          end

          def update_or_create(hash)
            sheet = nil
            if id = hash[:id]
              sheet = find(id: id).first.extend(SheetFileExtension)
            end
            sheet = create(hash) unless sheet

            sheet.populate(hash)
            return sheet
          end

          def create(content)
            now = Time.now
            ncontent = content.kind_of?(String) ? content : content.delete(:content)
            hash = {
              :id         => Ha2itat::Database.get_random_id,
              :content    => ncontent,
              :created_at => now,
              :updated_at => now,
              :user_id    => @user.id
            }
            if content.kind_of?(Hash)
              hash.merge!(content)
            end
            
            super(hash)
          end

          def cleaned_linebreaks(content)
            content.gsub(/\r\n?/, "\n")
          end

          def cleaned_sheet_object(sheet)
            stw = sheet.dup
            [:content, :user, :markdown_file, :file].each do |iv|
              stw.remove_instance_variable("@#{iv}") if stw.instance_variable_get("@#{iv}")
            end
            stw
          end

          
          def store(sheet)
            raise "invalid sheet: #{PP.pp(sheet, '')}" unless sheet.valid?

            ::FileUtils::mkdir_p(directory_for(sheet), :verbose => true)
            ::FileUtils::mkdir_p(data_dir_for(sheet), :verbose => true)
            sheet.updated_at = Time.now

            write(filename_for(sheet), cleaned_linebreaks(sheet.content))

            sheet_to_write = cleaned_sheet_object(sheet)
            write(realpath(metadata_file_for(sheet)), YAML.dump(sheet_to_write))
            sheet
          end

          def destroy(sheet)
            ::FileUtils.rm_rf(data_dir_for(sheet), verbose: true)
            ::FileUtils.rm_rf(directory_for(sheet), verbose: true)
          end

          def hash_for_image(file)
            Digest::SHA1.hexdigest(::File.new(file).read) 
          end

          def upload(sheet, params)
            ret = []
            params.each do |input_hash|

              ext = ::File.extname(input_hash[:filename])
              fn = "%s%s" % [hash_for_image(input_hash[:tempfile]), ext]
              target = sheet.data_dir(fn)

              ::FileUtils.mkdir_p(sheet.data_dir)
              ::FileUtils.copy(input_hash[:tempfile].path, target, :verbose => true)
              ret.push({fn => sheet.http_path(fn)})
            end
            ret 
          end

          def update_sheet(sheet, param_hash)
            sheet = sheet.extend(SheetFileExtension)
            needs_update = false

            param_hash.each do |param, value|
              needs_update = true
              sheet.send("%s=" % [param.to_s], value)
            end

            if needs_update
              sheet.updated_at = Time.now
              store(sheet)
            end
            sheet

          end
          
        end
      end
    end
  end


end
