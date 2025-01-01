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

          def entry_files(uid = nil)
            files = Dir.glob("%s/*/*.yaml" % repository_path(user_path(uid)))
          end

          def yaml_load(file:)
            Psych.unsafe_load(::File.readlines(file).join)
          end

          def read(uid = nil)
            target_id = uid || @user.id rescue nil
            raise Ha2itat::Database::NoUserContext, "no user context" unless target_id

            user_entries = []
            entry_files(target_id).each do |entryfile|
              user_entries << yaml_load(file: entryfile)
            end
            user_entries
          end

          def by_id(id)
            read.select{ |uentry| uentry =~ id }.shift rescue nil
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

          def exist?(entry)
            ::File.exist?(repository_path(entry.filename))
          end

          def store(entry)
            validate!(entry)

            human_kind = "creating"
            if exist?(entry)
              human_kind = "updating"
              entry.updated_at = Time.now
            end

            # do that before we prare for saving because it touches #user
            # which we dont want to have in our result yaml
            complete_path = repository_path(entry.filename)
            
            to_save = prepare_for_save(entry)
            yaml = YAML::dump(to_save)

            dirname = ::File.dirname(complete_path)
            ::FileUtils.mkdir_p(dirname, verbose: true) unless ::File.exist?(dirname)

            human_kind = exist?(entry) ? "updating" : "creating"
            Ha2itat.log "#{human_kind} entry:#{entry.id} (#{entry.user.name})"
            write(complete_path, yaml)
            to_save
          end
        end
      end
    end
  end

end
