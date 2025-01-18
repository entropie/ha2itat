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
        newdeck
      end

      def push(*decks)
        decks.each do |dck|
          @decks << dck
        end
      end

      def each(&blk)
        @decks.each(&blk)
      end

      def map(&blk)
        @decks.map(&blk)
      end

      def size
        @decks.size
      end

      def to_a
        @decks
      end

      def read_all
        @decks.map!{ |d| d.read }
      end

      def for(entry)
        read
        decks = Decks.new(path, user)
        entry.prefixed_tags.map do |entrydeck|
          decks.push( create(entrydeck.to_s) )
        end
        decks
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
        retdeck = @decks.select{ |d| d =~ obj }.shift
        if retdeck
          retdeck.read
          return retdeck
        end
        nil
      end

      def inspect
        "<Decks: user=%s %s>" % [user.name, @decks.map{ |dck| dck.name }.join(",")]
      end
    end


    class Deck

      include EntromentAdapter
      
      attr_reader :name, :decks

      def deckname_to_path(name = nil)
        (name || @name).scan(/[a-zA-Z0-9]/).join.downcase[0..16]
      end

      def initialize(name, decks)
        @name = deckname_to_path(name)
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
        @cards ||= Cards.new
      end

      def size
        cards.size
      end

      def id_present?(oid)
        cards.any?{ |c| c =~ oid }
      end

      def sync(entry)
        crd = Card.new(entry, self)
        crd = crd.read_or_setup
        cards.push(crd)
        self
      end

      def new_session(**opts)
        @session = nil
        session(**opts)
      end

      def session(**opts)
        @session = nil if not opts.empty?
        @session ||=
          begin
            session = Session.new(self, **opts)
            Ha2itat.log("entroment session:start #{session.id} #{PP.pp(opts, '')}")
            cards.by_due.each do |card|
              session.add(card)
            end
            session.start
            session
          end
      end

      def sessions
        Sessions.load(self)
      end

      def create
        unless exist?
          Ha2itat.log("entroment deck:create #{name}")
          FileUtils.mkdir_p(path, verbose: true)
        end
        self
      end

      def yaml_load(file:)
        Psych.unsafe_load(::File.readlines(file).join)
      end
      
      def read
        @cards = Cards.new
        Dir.glob("%s/card*" % path).each do |a|
          @cards.push(yaml_load(file: a))
        end
        self
      end

      def remove(entry)
        @cards.delete_if{ |card|
          if card =~ entry.id
            card.destroy
            true
          else
            false
          end
        }
        self
      end
      
    end
  end
end
