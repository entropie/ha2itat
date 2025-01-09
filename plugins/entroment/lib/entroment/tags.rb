module Plugins
  module Entroment

    module Tags
      def self.from_array(*arr)
        Tags.new.push(*arr)
      end

      class Tags < Array
        def class_for(tag)
          ret = tag.include?(":") ? PrefixedTag : Tag
          ret.new(tag)
        end

        def push(*elements)
          elements.each do |tagele|
            self << class_for(tagele)
          end
          self
        end

        def prefixed
          dup.reject!{ |t| !t.kind_of?(PrefixedTag) }
        end
      end

      class Tag
        def initialize(tag)
          @tag = tag
        end

        def ==(other)
          @tag == other
        end

        def inspect
          "#{@tag}"
        end
      end

      class PrefixedTag < Tag
        def identifier
          @tag.split(":").last
        end

        def prefix
          @tag.split(":").first
        end

        def inspect
          "SR(#{identifier})"
        end
      end
    end
  end
end
