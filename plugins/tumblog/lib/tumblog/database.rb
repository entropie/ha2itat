module Plugins
  module Tumblog

    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    module Database

      extend Ha2itat::Database

      class Adapter

        class File < Ha2itat::Database::Adapter

          TUMBLPOST_EXTENSION = ".tpost.yaml".freeze

          include Ha2itat::Mixins::FU

          def initialize(path)
            @path = path
          end

          def path(*args)
            ::File.join(@path, *args)
          end

          def adapter_class(create = false)
            Post
          end

          def setup
            @setup = true
            log :debug, "setting up adapter directory #{path}"
            FileUtils.mkdir_p(path)
            @setup
          end

          def repository_path(*args)
            ::File.join(path, "tumblog", *args)
          rescue Errno::ENOENT
            warn "does not exist: #{path("blog")}"
            path("tumblog", *args)
          end

          def post_filename(post)
            repository_path(post.id + TUMBLPOST_EXTENSION)
          end

          def exist?(post)
            ::File.exist?(post.path)
          end

          def datadir(*args)
            ::File.expand_path(relative_datadir(*args))
          end

          def relative_datadir(*args)
            ::File.join("media/tumblog/data", *args)
          end

          def post_files
            fileglob = -> (directory) {
              toglob = repository_path(directory) + "/*" + TUMBLPOST_EXTENSION
              Dir.glob(toglob)
            }
            files = []
            files.push(*fileglob.call("entries/*"))
            files
          end

          def by_id(id)
            entries.select{|e| e.id == id}.first
          end

          def by_tags(*tag)
            entries.select{|e| e.tags.any?{|pt| tag.include?(pt)} }
          end


          def entries(user = nil)
            @posts = Entries.new(user || @user).push(*post_files.map{|pfile| load_file(pfile)})
            @posts.reject!{|post| post.private? } unless @user
            @posts
          end

          def load_file(yamlfile)
            YAML::load_file(yamlfile, aliases: true, permitted_classes: [Plugins::Tumblog::Post, Time, Symbol])
          end

          def create(param_hash)
            adapter_class(true).new(self).populate(param_hash)
          end


          def update(post)
            log "updating #{post.id} #{post.filename}"
            write(post.file, post.to_yaml)
            post
          end

          def store(post)
            log "tumblog:STORE:#{post.id}"

            post.user_id ||= @user.id
            post.datadir ||= post.relative_datadir
            post.filename ||= post.relative_filename

            unless exist?(post)
              FileUtils.mkdir_p(post.path, :verbose => true)
              FileUtils.mkdir_p(post.datadir, :verbose => true)
            else
              post.updated_at = Time.now
            end
            write(post.file, post.to_yaml)
            post
          end

          def upload(post, obj)
            post.upload(obj)
          end

          def destroy(post)
            log "tumblog:REMOVE:#{post.title}"
            rm_rf(post.file)
            rm_rf(post.datadir)
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
