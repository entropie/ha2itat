module Plugins
  module Entroment

    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    module Database

      extend Ha2itat::Database

      class Adapter
        class File < Ha2itat::Database::Adapter

          include Ha2itat::Mixins::FU
          PERMITTED_CLASSES = []

          attr_accessor :user

          def initialize(path)
            @path = path
          end

          def path(*args)
            ::File.join(@path, *args)
          end

          def repository_path(*args)
            ::File.join(::File.realpath(path), "entroment", *args)
          rescue Errno::ENOENT
            warn "does not exist: #{path("user")}"
            path("entroment", *args)
          end

          def user_path(uid = nil)
            target_id = uid || @user.id rescue nil
            raise Ha2itat::Database::NoUserContext, "no user context" unless target_id
            ::File.join("entries", target_id)
          end

          # def relative_path_for(entry)
          #   ::File.join(user_path, entry.time_to_path, sheet.id)
          # end
      
          # def relative_filename_for(entry)
          #   ::File.join(relative_path_for(entry), entry.filename)
          # end

          def entry_files(uid = nil)
            files = Dir.glob("%s/*/*.yaml" % repository_path(user_path(uid)))
          end

          def read(uid = nil)
            target_id = uid || @user.id rescue nil
            raise Ha2itat::Database::NoUserContext, "no user context" unless target_id
            puts
            user_entries = []
            entry_files(target_id).each do |entryfile|
              user_entries << YAML::load(entryfile)
            end
          end

          def by_id(id)
            read
          end

          def with_user(user, &blk)
            @user = user
            ret = nil
            begin
              ret = yield self if block_given?
            ensure
              @user = nil
            end
            return ret || self
          end

          def setup
            @setup = true
            Ha2itat.log "setting up adapter directory #{path}"
            FileUtils.mkdir_p(path)
            @setup
          end

          def validate_user(entry)
            if entry.user and entry.user == @user
              return true
            end
          end

          def validate!(entry)
            validate_user(entry) or
              raise Ha2itat::Database::NoUserContext, "entry #{PP.pp(entry, "")} no user context"
          end

          def prepare_for_save(entry)
            entry.prepare_for_save
          end

          def create(**param_hash)
            params = param_hash
            params = param_hash.merge(user_id: @user.id) if @user
            entry = Entry.new(**params)
            store(entry)
          end

          def store(entry)
            validate!(entry)

            to_save = prepare_for_save(entry)
            yaml = YAML::dump(to_save)
            complete_path = repository_path(to_save.filename)
            ::FileUtils.mkdir_p(::File.dirname(complete_path), verbose: true)

            Ha2itat.log "storing entry:#{entry.id} (#{entry.user.name})"
            write(complete_path, yaml)
            entry
          end
        end
      end
    end
  end

end
