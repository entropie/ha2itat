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
          only_prefixes = dup.select{ |t| t.kind_of?(PrefixedTag) }
          only_prefixes
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

        def to_s
          @tag
        end
        alias :complete_string :to_s
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

        def to_s
          identifier
        end

        def complete_string
          @tag
        end
      end
    end
  end
end
