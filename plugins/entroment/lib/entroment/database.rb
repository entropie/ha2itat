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

          def deck_path(uid = nil)
            ::File.join(user_path(uid), "decks")
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
              @user = nil
            end
            return ret
          end
          
          def decks
            @decks ||=
              begin
                ds = Decks.new(deck_path, @user)
                ds.read
                ds
              end
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

          def synchronize_decks(entry)
            decks2sync = decks.for(entry)
            decks2sync.each do |d2s|
              d2s.sync(entry)
            end
            decks2sync
          end

          def cards_for(entry)
            dp = ::File.join(repository_path, deck_path)
            card_yaml_files = ::File.join(dp, "*", "card-%s" % ::File.basename(entry.filename))
            cards = Dir.glob(card_yaml_files).map{ |cf|
              yl = yaml_load(file: cf)
            }
            cards
          end

          def create(**param_hash)
            params = param_hash
            params = param_hash.merge(user_id: @user.id) if @user
            entry = Entry.new(**params)

            # to be sure
            while !(b = by_id(entry.id)).nil?
              Ha2itat.log("entroment entry:create #{entry.id} already in database, requesting new")
              entry.newid!
            end

            store(entry)
          end

          def remove_card(card)
            Ha2itat.log("entroment card:remove #{card.id}/#{card.entry.id} by #{user.name}")
            ::FileUtils.rm_rf(card.path, verbose: true)
          end

          def write_card(card)
            to_save = card.prepare_for_save.dup
            yaml = YAML::dump(to_save)
            Ha2itat.log("entroment card:write for \##{card.id}:#{card.path}")
            ::File.open(card.path, "w+") {|fp| fp.puts(yaml) }
            card
          end

          def write_session(session)
            sessiondir = session.path
            ::FileUtils.mkdir_p(sessiondir, verbose: true) unless ::File.exist?(sessiondir)
            Ha2itat.log("entroment: session:write #{session.id}:#{session.file}")
            session.updated_at = Time.now
            yaml = YAML::dump(session.prepare_for_save.dup)
            ::File.open(session.file, "w+"){ |fp| fp.puts(yaml) }
            session
          end

          def destroy_session(session)
            Ha2itat.log("entroment: session:destroy #{session.id}:#{session.file}")
            ::FileUtils.rm_rf(session.file, verbose: true)
          end

          def update(entry, **param_hash)
            params = param_hash
            params = param_hash.merge(user_id: @user.id) if @user

            oldtags = entry.tags
            entry.update(param_hash)
            tags = entry.tags

            # remove entry from deck if no longer tagged
            oldtags.each do |oldtag|
              unless tags.include?(oldtags)
                deck = decks[oldtag.to_s]
                deck.remove(entry) if deck
              end
            end
            store(entry)
          end

          def exist?(entry)
            ::File.exist?(repository_path(entry.filename))
          end

          def find(content: nil, tags: [], date: nil)
            result = []
            if content
              result.push *read.select{ |entry| entry.content.include?(content) }
            end
            result
          end

          def store(entry)
            validate!(entry)

            human_kind = "creating"
            if exist?(entry)
              human_kind = "updating"
              entry.updated_at = Time.now
            end

            # do that before we prepare for saving because it touches #user
            # which we dont want to have in our result yaml
            complete_path = repository_path(entry.filename)
            
            to_save = prepare_for_save(entry)
            yaml = YAML::dump(to_save)

            dirname = ::File.dirname(complete_path)
            ::FileUtils.mkdir_p(dirname, verbose: true) unless ::File.exist?(dirname)

            Ha2itat.log "entroment entry:#{human_kind} #{entry.id} (#{entry.user.name})"
            write(complete_path, yaml)

            if entry.decked?
              synchronize_decks(entry)
            end
            to_save
          end

          def destroy(entry)
            entry.cards.each do |card|
              remove_card(card)
            end
            Ha2itat.log "entroment entry:delete %s:%s user '%s'" % [entry.id, entry.filename, entry.user.name]
            ::FileUtils.rm_rf(entry.complete_path, verbose: true)
            true
          end
        end
      end
    end
  end

end
