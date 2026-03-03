module Plugins
  module Polygram

    class Case
      class Document
        TIMESTAMP_LINE_RE = /\A(\d+):(?:(\d+)\s+|\s+)(.+)\z/

        module DocumentHTMLOutput
          MARKER_LINE_RE = /\A(\d+):(?:(\d+)\s+|\s+)(.+)\z/

          def linkify_marker_lines(text)
            return "" if text.nil? || text.empty?

            text.each_line.map do |line|
              stripped = line.strip
              next line if stripped.empty?

              m = MARKER_LINE_RE.match(stripped)
              next line unless m

              ts = m[1].to_i
              duration = m[2] ? m[2].to_i : nil
              content = m[3].strip

              hash = +"#t=#{ts}"
              hash << "&d=#{duration}" if duration && duration > 0

              "[#{ts}](#{hash}): #{content}\n"
            end.join
          end


          def to_html
            Ha2itat::Renderer.render(:markdown, linkify_marker_lines(self))
          end
        end


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
          @text.extend(DocumentHTMLOutput)
        rescue
          nil
        end

        def extract_markers(txt = nil)
          txt ||= (exist? ? text : nil)
          return [] unless txt

          markers = []

          txt.each_line do |line|
            line = line.strip
            next if line.empty?

            m = TIMESTAMP_LINE_RE.match(line)
            next unless m

            ts = m[1].to_i
            duration = m[2] ? m[2].to_i : nil
            content = m[3].strip

            marker = { ts: ts, text: content }
            marker[:duration] = duration if duration && duration > 0
            markers << marker
          end

          markers
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

