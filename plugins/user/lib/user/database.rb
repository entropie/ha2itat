require "jwt"
require "bcrypt"

module Plugins


  module User

    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end


    module Database

      extend Ha2itat::Database

      class Adapter
        class File < Ha2itat::Database::Adapter

          USERFILE_EXTENSION = ".user.yaml".freeze

          include Ha2itat::Mixins::FU

          def initialize(path)
            @path = path
          end

          # def permitted_classes
          #   [Plugins::User::User, BCrypt::Password, Plugins::User::Groups]
          # end

          def path(*args)
            ::File.join(@path, *args)
          end

          def adapter_class
            User
          end

          def repository_path(*args)
            ::File.join(::File.realpath(path), "user", *args)
          rescue Errno::ENOENT
            warn "does not exist: #{path("user")}"
            path("user", *args)
          end

          def setup
            @setup = true
            Ha2itat.log "setting up adapter directory #{path}"
            FileUtils.mkdir_p(path)
            @setup
          end

          def user_files
            Dir.glob(repository_path + "/*" + USERFILE_EXTENSION)
          end

          def yaml_load(file:)
            Psych.unsafe_load(::File.readlines(file).join)
          end

          def user(username = nil)
            if username
              fn = User.filename(username)
              retuser = yaml_load(file: repository_path(fn))
              return retuser
            else
              user_files.map{|uf|
                yaml_load(file: uf)
              }
            end
          end

          def by_id(id)
            user.select{|u| u == id }.first
          end

          def by_name(name)
            user.select{|u| u.name == name}.first
          end

          def by_token(token)
            decoded = JWT.decode(token, Ha2itat.quart.secret, true, { algorithm: 'HS256' })
            e = decoded.first
            usr = by_id(e["user_id"])
            if usr.password.to_s == e["password"]
              return usr
            else
              return nil
            end
          rescue JWT::VerificationError
            return nil
          end

          def create(param_hash)
            usr = User.new.populate(param_hash)
            store(usr)
            usr
          end

          def store(usr)
            filename = repository_path(usr.filename)
            FileUtils.mkdir_p(::File.dirname(filename))
            Ha2itat.log "storing user:#{usr.name}"
            write(filename, YAML::dump(usr))
          end
        end
      end
    end
  end

end
