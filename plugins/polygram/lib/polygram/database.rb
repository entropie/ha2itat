module Plugins
  module Polygram

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

          # def path(*args)
          #   repository_path(@id)
          # end

          def repository_path(*args)
            ::File.join(::File.realpath(@path), "polygram", *args)
          rescue Errno::ENOENT
            warn "does not exist: #{path("user")}"
            path("polygram", *args)
          end

          def case_path(*args)
            repository_path("cases", *args)
          end

          # def entry_files(uid = nil)
          #   Dir.glob("%s/*/*.yaml" % repository_path(user_path(uid)))
          # end

          # def yaml_load(file:)
          #   Psych.unsafe_load(::File.readlines(file).join)
          # end

          def read(uid = nil)
            target_id = uid || @user.id rescue nil
            raise Ha2itat::Database::NoUserContext, "no user context" unless target_id

            user_entries = []
            entry_files(target_id).each do |entryfile|
              user_entries << yaml_load(file: entryfile)
            end
            user_entries
          end
          alias :entries :read

          def by_id(id, uid = nil)
            read(uid).select{ |uentry| uentry =~ id }.shift
          end

          def by_tags(*search_tags)
            entries.select do |entry|
              (entry.tags & search_tags).any?
            end
          end

          def with_user(user, &blk)
            @user = user
            ret = nil
            begin
              ret = yield self if block_given?
            ensure
              @user, @decks = nil, nil
            end
            return ret
          end

          # def setup
          #   @setup = true
          #   Ha2itat.log "setting up adapter directory #{path}"
          #   FileUtils.mkdir_p(path)
          #   @setup
          # end

          def create(**param_hash)
            ret = Case.new(**param_hash)
            ret
            # params = param_hash
            # params = param_hash.merge(user_id: @user.id) if @user
            # entry = Entry.new(**params)

            # # to be sure
            # while !(b = by_id(entry.id)).nil?
            #   Ha2itat.log("entroment entry:create #{entry.id} already in database, requesting new")
            #   entry.newid!
            # end

            # store(entry)
          end

          def update(entry, **param_hash)
            # params = param_hash
            # params = params.merge(user_id: @user.id) if @user

            # oldtags = entry.tags
            # entry.update(param_hash)
            # tags = entry.tags

            # # remove entry from deck if no longer tagged
            # oldtags.select{ |ot| not tags.include?(ot) }.each do |oldtag|
            #   deck = decks[oldtag.to_s]
            #   deck.remove(entry) if deck
            # end
            # store(entry)
          end

          def exist?(entry)
            ::File.exist?(repository_path(entry.filename))
          end

          def find(content: nil, tags: [], date: nil)
            # result = []
            # if content
            #   result.push(*read.select{ |entry| entry.content.include?(content) })
            # end
            # result
          end

          def store(entry)
            # validate!(entry)

            # human_kind = "creating"
            # if exist?(entry)
            #   human_kind = "updating"
            #   entry.updated_at = Time.now
            # end

            # # do that before we prepare for saving because it touches #user
            # # which we dont want to have in our result yaml
            # complete_path = repository_path(entry.filename)

            # to_save = prepare_for_save(entry)
            # yaml = YAML::dump(to_save)

            # dirname = ::File.dirname(complete_path)
            # ::FileUtils.mkdir_p(dirname, verbose: true) unless ::File.exist?(dirname)

            # Ha2itat.log "entroment entry:#{human_kind} #{entry.id} (#{entry.user.name})"
            # write(complete_path, yaml)

            # if entry.decked?
            #   synchronize_decks(entry)
            # end
            # to_save
          end

          def destroy(entry)
          end
        end
      end
    end
  end

end
