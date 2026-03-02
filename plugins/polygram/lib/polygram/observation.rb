module Plugins
  module Polygram

    class Case
      class Document
        attr_reader :caze, :mid, :user
        def initialize(caze, mid, user)
          @caze = caze
          @mid = mid
          @user = user
        end

        def media
          @caze.media[@mid]
        end

        def text
          @text = ::File.read(path)
        end

        def exist?
          ::File.exist?(path)
        rescue
          false
        end
      end

      class Observation < Document
        def self.find_or_create(caze, mid, user)
          obs = Ha2itat.adapter(:polygram).observation_for(caze, mid, user)
        end

        def path
          caze.path("annotations/#{user.id}/#{mid}/observation.markdown")
        end
      end

      class Reading < Document
        def self.find_or_create(caze, mid, user)
          obs = Ha2itat.adapter(:polygram).reading_for(caze, mid, user)
        end

        def path
          caze.path("annotations/#{user.id}/#{mid}/reading.markdown")
        end
      end
    end

  end
end

