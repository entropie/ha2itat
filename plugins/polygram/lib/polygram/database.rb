require "streamio-ffmpeg"


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

          def media_files(caze)
            Dir.glob("%s/*" % caze.storage_path)
          end

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

          def create(**param_hash)
            kind = param_hash.delete(:kind)
            kind ||= :videos
            clz = kind == :images ? ImagesCase : VideosCase

            ret = clz.new(**param_hash)
            ret
          end

          def update(entry, **param_hash)
          end

          def exist?(entry)
            ::File.exist?(repository_path(entry.filename))
          end

          def find(content: nil, tags: [], date: nil)
          end

          def normalize_video(ifile, ofile, **param_hash)
            video = FFMPEG::Movie.new(ifile)
            video.transcode(ofile, %w[
              -vf fps=25,scale=iw:-2
              -c:v libx264 -preset fast -crf 23
              -x264-params keyint=50:min-keyint=50
              -c:a aac -b:a 128k
              -movflags +faststart
            ])
          end

          def handle_normalized_video(target_file, normalized_file)
            if ::File.exist?(target_file) and ::File.exist?(normalized_file)
              Ha2itat.log "polygram handle_normalized_video:removing uploaded filed after normalization #{target_file}"
              ::FileUtils.rm(target_file, verbose: true)
            else
              Ha2itat.log "polygram handle_normalized_video:both files do not exist and therefore we delete nothing: #{target_file}"            end
          end

          def observations_for(entry)
            res = []
            entry.media.each do |casemedia|
              observation_path_glob = entry.path("observation/*/#{casemedia.mid}/observation.markdown")
              observation_files = Dir.glob(observation_path_glob)
              observation_files.each do |file|
                uid = file.split("/")[-3]
                observation = Case::Observation.new(entry, casemedia.id, Ha2itat.adapter(:user).by_id(uid))
                res << observation
              end
            end
            res
          end

          def readings_for(entry)
            res = []
            entry.media.each do |casemedia|
              reading_path_glob = entry.path("observation/*/#{casemedia.mid}/reading.markdown")
              reading_files = Dir.glob(reading_path_glob)
              reading_files.each do |file|
                uid = file.split("/")[-3]
                reading = Case::Reading.new(entry, casemedia.id, Ha2itat.adapter(:user).by_id(uid))
                res << reading
              end
            end
            res

          end

          def observation_for(entry, mid, user)
            Case::Observation.new(entry, mid, user)
          end

          def reading_for(entry, mid, user)
            Case::Reading.new(entry, mid, user)
          end

          def reading_and_observation_set_for(entry, mid, user)
            return [reading_for(entry, mid, user), observation_for(entry, mid, user)]
          end

          def edit_observation(entry, mid, user, text)
            obs = Case::Observation.find_or_create(entry, mid, user)
            FileUtils.mkdir_p(::File.dirname(obs.path), verbose: true)
            ::File.open(obs.path, "w+"){ |fp| fp.write(text) }
            obs
          end

          def edit_reading(entry, mid, user, text)
            obs = Case::Reading.find_or_create(entry, mid, user)
            FileUtils.mkdir_p(::File.dirname(obs.path), verbose: true)
            ::File.open(obs.path, "w+"){ |fp| fp.write(text) }
            obs
          end

          def upload_for(entry, path: nil, file: nil, ext: nil)
            Ha2itat.log "polygram upload_for:#{entry.id} (path=#{path},file=#{file and file.size })"
            fc = nil
            if path
              fc = ::File.read(path)
              ext = ::File.extname(path).gsub(/\./, "")
            elsif file
              fc = file
            end

            raise "upload failed" unless fc
            raise "ext parameter missing; we dont guess extensions" unless ext

            fdig = Digest::SHA1.hexdigest(Ha2itat.quart.secret + fc)

            # write
            filename = "tainted-%s.%s" % [fdig, ext]
            target_file = entry.storage_path(filename)
            Ha2itat.log "polygram upload_for:writing #{target_file}"
            FileUtils.mkdir_p(::File.dirname(target_file), verbose: true)
            bytes = ::File.open(target_file, "w"){ |fp| fp.write(fc) }

            # normalize
            normalized_file = entry.storage_path("%s.%s" % [fdig, ext])
            Ha2itat.log "polygram upload_for:wrote %i bytes to %s" % [bytes, target_file]
            if normalize_video(target_file, normalized_file)
              handle_normalized_video(target_file, normalized_file)
            end

            bytes
          end

          def store(entry)
            FileUtils.mkdir_p(repository_path, verbose: true)
            pp entry.metadata
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
