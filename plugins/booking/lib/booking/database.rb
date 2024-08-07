module Plugins

  module Booking

    module Database

      extend Ha2itat::Database

      class Adapter

        class File < Ha2itat::Database::Adapter

          include Ha2itat::Mixins::FU


          def initialize(path)
            @path = path
          end

          def permitted_classes
            [Plugins::Booking::Events::Event]
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
            ::File.join(::File.realpath(path), "booking", *args.compact.map(&:to_s))
          rescue Errno::ENOENT
            warn "does not exist: #{path("booking")}"
            path("booking", *args)
          end

          def events(year: Time.now.strftime("%y"), month: Time.now.strftime("%m"))
            @events = Booking::Events.new(self, year: year, month: month).read.sorted
            @events
          end

          def events_all
            events(year: nil, month: nil)
          end

          def events_published
            Plugins::Booking::Events.new(self).push(*events_all.select{ |e| e.published? })
          end

          def events_archived
            aevents = Booking::ArchivedEvents.new(self).read.sorted
            Booking::ArchivedEvents.new(self).push(*aevents)
          end

          def by_slug(slug)
            events_all.by_slug(slug)
          end

          def create(what, params)
            tclazz = case what
                     when :event
                       Booking::Events::Event
                     end
            to_create = tclazz.create(Booking::Events::Event.normalize_params(params))
            store(to_create)
            to_create
          end

          def update(what, params)
            old = what.clone
            updated = what.update(params)

            # bugfix: when day/month/year is changed, we have to remove old source.yaml to avoid
            # having multiple entries with the same ID
            if old.filename != updated.filename
              rm(repository_path(old.filename), verbose: true)
            end

            store(updated)
            updated
          end

          def find_update_or_create(param_hash)
            params = Booking::Events::Event.normalize_params(param_hash)
            slug = param_hash[:slug]
            ev = by_slug(slug)
            if ev
              return ev
            else
              create(:event, params)
            end
          end

          def store(what)
            raise Ha2itat::Database::EntryNotValid, "#{what.class}#valid? returns not true" unless what.valid?

            log "booking:store:#{what.slug}"

            target_file = repository_path(what.filename)

            if what.exist?
              existing = by_slug(what.slug)

              if existing.start_date != what.start_date
                rm(repository_path(existing.filename), verbose: true)
              else
                rm(target_file, verbose: true)
              end

              what.updated_at = Time.now
            else
              mkdir_p(::File.dirname(target_file))
              what.created_at = Time.now
            end

            write(target_file, what.to_yaml)
          end

          def archive(what)
            raise Ha2itat::Database::EntryNotValid, "#{what.class}#valid? returns not true" unless what.valid?
            log "booking:archive:#{what.slug}"
            target_file = repository_path(what.filename)

            new_filename = ArchivedEvents.event_filename(what)
            ::FileUtils.mv(target_file, ArchivedEvents.path(new_filename), :verbose => true)
            nil
          end


          def destroy(what)
            raise "trying to destroy not existing `#{what.slug}'" unless what.exist?
            log "booking:REMOVE:#{what.slug}"
            begin
              rm(what.image.fullpath, verbose: true)
            rescue
            end
            rm(repository_path(what.filename), verbose: true)
          end

          def upload(event, obj)
            event = event.upload(obj)
            store(event)
            event
          end

          def with_user(user, &blk)
            @user, @events = user, nil
            ret = yield self if block_given?
            ret || self
          end

        end

      end

    end

  end
end
