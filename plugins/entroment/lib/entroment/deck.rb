module Plugins
  module Entroment
    class Decks

      include EntromentAdapter

      attr_reader :path, :user

      def initialize(path, user)
        @path = path
        @user = user
        @decks = []
      end

      def create(name)
        newdeck = Deck.new(name, self)
        newdeck.create
        load_deck(newdeck)
      end

      def include?(deck)
        @decks.any?{ |ds| ds.name == deck.name }
      end

      def load_deck(deck)
        @decks << deck unless include?(deck)
      end

      def read
        basepath = adapter { |a| a.repository_path(path) }
        Dir.glob("%s/*" % basepath).each do |deckpath|
          read_deck = Deck.new(::File.basename(deckpath), self)
          load_deck(read_deck)
        end
        self
      end

      def [](obj)
        @decks.select{ |d| d =~ obj }.shift
      end

    end

    class Deck

      include EntromentAdapter
      
      attr_reader :name, :decks

      def deckname_to_path
        name.scan(/[a-zA-Z0-9]/).join.downcase[0..16]
      end

      def initialize(name, decks)
        @name = name
        @decks = decks
      end

      def =~(obj)
        if obj.kind_of?(Deck)
          @name == obj.name
        elsif obj.kind_of?(Symbol) or obj.kind_of?(String)
          @name == obj.to_s
        end
      end

      def user
        @decks.user
      end

      def inspect
        "<Deck:%s user=%s cards=%s>" % [name, user.name, cards.size]
      end

      def path
        @path ||= adapter{ |adptr| adptr.repository_path(decks.path, deckname_to_path) }
      end

      def exist?
        ::File.exist?(path)
      end

      def cards
        []
      end

      def create
        FileUtils.mkdir_p(path, verbose: true) unless exist?
      end

    end
  end
end
