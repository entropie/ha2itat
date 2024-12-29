module Plugins
  module Entromind

    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    module Database

      extend Ha2itat::Database

      class Adapter
        class File < Ha2itat::Database::Adapter

          include Ha2itat::Mixins::FU

          def initialize(path)
            @path = path
          end

          def path(*args)
            ::File.join(@path, *args)
          end

          def repository_path(*args)
            ::File.join(::File.realpath(path), "entromind", *args)
          rescue Errno::ENOENT
            warn "does not exist: #{path("user")}"
            path("entromind", *args)
          end

          def relative_path_for(entry)
            ::File.join(user_path, entry.time_to_path, sheet.id)
          end
      
          def relative_filename_for(entry)
            ::File.join(relative_path_for(entry), entry.filename)
          end


          def setup
            @setup = true
            Ha2itat.log "setting up adapter directory #{path}"
            FileUtils.mkdir_p(path)
            @setup
          end

          def create(param_hash)
            # usr = User.new.populate(param_hash)
            # store(usr)
            # usr
          end

          def store(usr)
            # filename = repository_path(usr.filename)
            # FileUtils.mkdir_p(::File.dirname(filename))
            # Ha2itat.log "storing user:#{usr.name}"
            # write(filename, YAML::dump(usr))
          end
        end
      end
    end
  end

end
