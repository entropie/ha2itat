module Plugins

  module Blog

    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    module Database

      extend Ha2itat::Database

      class Adapter

        class File < Ha2itat::Database::Adapter

          BLOGPOST_EXTENSION = ".post.yaml".freeze

          include Ha2itat::Mixins::FU

          def initialize(path)
            @path = path
          end

          def path(*args)
            ::File.join(@path, *args)
          end

          def adapter_class(create = false)
            create ? Draft : Post
          end

          def setup
            @setup = true
            log "setting up adapter directory #{path}"
            FileUtils.mkdir_p(path)
            @setup
          end

          def repository_path(*args)
            ::File.join(::File.realpath(path), "blog", *args)
          rescue Errno::ENOENT
            warn "does not exist: #{path("blog")}"
            path("blog", *args)
          end

          def post_filename(post)
            repository_path(post.slug + BLOGPOST_EXTENSION)
          end

          def exist?(post)
            ::File.exist?(post_filename(post))
          end

          def datadir(*args)
            ::File.join("public/data/blog", *args)
          end

          def post_files
            fileglob = -> (directory) {
              toglob = repository_path(directory) + "/*" + BLOGPOST_EXTENSION
              Dir.glob(toglob)
            }
            files = []
            files.push(*fileglob.call("drafts")) if @user
            files.push(*fileglob.call("posts"))
            files
          end

          def posts(user = nil)
            @posts = Posts.new(user || @user).push( *post_files.map{ |pfile| load_file(pfile) })
          end

          def sorted(user = nil)
            @sorted ||= posts.sort_by{|p| p.created_at}.reverse
          end

          def is_first?(post)
            sorted.first == post
          end

          def by_slug(slug)
            posts.dup.select{|p| p.slug == slug }.first
          end

          def by_template(tmpl)
            posts.dup.select{|p| p.template && p.template.to_sym == tmpl.to_sym }
          end

          def by_tags(tag)
            posts.dup.reject{|p| !p.tags.include?(tag) }
          end


          def load_file(yamlfile)
            log "loading %s" % yamlfile
            pc = [Plugins::Blog::Draft, Plugins::Blog::Post, Plugins::Blog::Image, Time]
            YAML::load_file(yamlfile,
                            aliases: true,
                            permitted_classes: pc)
          end

          def create(param_hash)
            adapter_class(true).new(self).populate(param_hash)
          end

          def update_or_create(param_hash)
            slug = if param_hash[:slug].nil? then Post.make_slug(param_hash[:title]) else param_hash[:slug] end
            post = by_slug(slug)

            if post
              updated = post.update(param_hash)
              return updated
            else
              create(param_hash)
            end
          end

          def store(post_or_draft, updated_at: Time.now)
            log :info, "blog:STORE:#{post_or_draft.title}"

            for_yaml = setup_post(post_or_draft)

            for_yaml.instance_variable_set("@updated_at", updated_at)

            write(for_yaml.fullpath, YAML.dump(for_yaml))
            FileUtils.mkdir_p(post_or_draft.datapath, :verbose => true)

            content = post_or_draft.content
            write(post_or_draft.datafile, content)

            # FIXME: ??
            # Ha2itat.plugin_enabled?(:cache) do
            #   Cache[:blog_last_modified] = Time.now
            #   Cache[post_or_draft.slug] = Time.now
            # end
            # post_or_draft
            for_yaml
          end

          def setup_post(post_or_draft)

            for_yaml = post_or_draft.for_yaml

            for_yaml.user_id = @user.id unless for_yaml.user_id

            unless exist?(post_or_draft)
              for_yaml.filename = post_or_draft.filename
              for_yaml.datadir = post_or_draft.datadir
            end
            for_yaml
          end

          def upload(post, obj)
            post.upload(obj)
          end

          def to_draft(post)
            log :info, "blog:DRAFT:#{post.title}"
            rm(post.fullpath, :verbose => true)
            store(post.to_draft(self))
          end

          def to_post(draft)
            log :info, "blog:UNDRAFT:#{draft.title}"
            rm(draft.fullpath, :verbose => true)
            store(draft.to_post(self))
          end

          def destroy(post_or_draft, lang = nil)
            complete_media_path = Ha2itat.quart.media_path(post_or_draft.datadir)
            log :info, "blog:REMOVE:#{post_or_draft.title}"
            rm(post_or_draft.fullpath, verbose: true)
            rm_rf(complete_media_path)
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
