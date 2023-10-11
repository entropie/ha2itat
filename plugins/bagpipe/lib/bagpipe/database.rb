module Plugins
  module Bagpipe

    def self.get_default_adapter_initialized
      if not (bp_root = Ha2itat.C(:bagpipe_root)).nil?
        bp_root = ::File.expand_path(bp_root)
        Database::Adapter.const_get(Ha2itat.default_adapter).new(bp_root)
      else
        raise "bagpipe plugin activated but no `bagpipe_root' entry in projectsettings"
      end
    end


    module Database

      extend Ha2itat::Database

      class Adapter

        class File < Ha2itat::Database::Adapter

          def initialize(path)
            @path = path
          end

          def path(*args)
            ::File.join(@path, *args)
          end

          def setup
            @setup = true
            log :debug, "setting up adapter directory #{path}"
            FileUtils.mkdir_p(path)
            @setup
          end

          def repository_path(*args)
            ::File.join(::File.realpath(path), *args)
          end

          # def datadir(*args)
          #   ::File.join("data", *args)
          # end

          def repository
            @repository ||= Bagpipe::Repository.new(@path)
          end

          def read(*string_path_or_array_of_segments)
            target = [string_path_or_array_of_segments].flatten
            target = target.map.map{|s|
              s.force_encoding(Encoding::UTF_8)
              CGI::unescape(s)
            }
            repository.read(target.join("/"))
          end

          def create(param_hash)
            raise NoUserContext, "trying to call #create without valid user context " unless @user
            raise
          end

          def update_or_create(param_hash)
            raise NoUserContext, "trying to call #create without valid user context " unless @user
            raise
          end

          def store(post_or_draft)
            raise NoUserContext, "trying to call #store without valid user context " unless @user
            raise
          end

          def with_user(user, &blk)
            @user, @posts = user, nil
            ret = yield self if block_given?
            #@user, @posts = nil, nil
            ret || self
          end

        end

      end

    end


  end
end
