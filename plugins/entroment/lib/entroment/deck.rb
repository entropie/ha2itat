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
        retdeck.read
        retdeck
      end

      def inspect
        "<Decks: user=%s %s>" % [user.name, @decks.map{ |dck| dck.name }.join(",")]
      end
    end

    class Cards < Array
    end
    
    class Card
      include EntromentAdapter

      attr_reader :entry, :deck

      SRFields = [
        :last_reviewed,
        :repetition_count,
        :correct_count,
        :incorrect_count,
        :interval,
        :easiness_factor,
      ]
        #     { "date": "2025-01-09", "response": "hard", "interval": 7 },
      #     { "date": "2025-01-10", "response": "good", "interval": 15 }

      SRFieldsDefaults = {
        last_reviewed: Time.now,
        repetition_count: 0,
        correct_count: 0,
        incorrect_count: 0,
        interval: 1,
        easiness_factor: 2.5
      }


      def initialize(entry, deck)
        @deck = deck
        @entry = entry
        @entry_id = entry.id
      end

      def =~(other)
        if other.kind_of?(String)
          @entry_id == other
        end
      end

      def entry
        if @entry
          @entry
        else
          adapter{ |adptr| adptr.by_id(@entry_id) }
        end
      end

      def user
        @user ||= Ha2itat.adapter(:user).by_id(@user_id)
      end

      def hash_to_instance_variables(hash)
        hash.each_pair{ |h,k|
          instance_variable_set("@%s" % h, k)
        }
      end

      def prepare_for_save
        @deckname = deck.name
        @user_id = entry.user.id
        remove_instance_variable("@entry") rescue nil
        remove_instance_variable("@deck") rescue nil
      end
      
      def write
        to_save = self.dup
        to_save.prepare_for_save
        yaml = YAML::dump(to_save)
        Ha2itat.log("deck:card writing for \##{entry.id}:#{path}")
        ::File.open(path, "w+") {|fp| fp.puts(yaml) }
      end

      def path
        ::File.join(deck.path, "card-%s" % ::File.basename(entry.filename))
      end

      def exist?
        ::File.exist?(path)
      end

      def yaml_load(file:)
        Psych.unsafe_load(::File.readlines(file).join)
      end

      def read_or_setup
        if not exist?
          hash_to_instance_variables(SRFieldsDefaults)
          write
          self
        else
          yaml_load(file: path)
        end
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

      def id_present?(oid)
        cards.any?{ |c| c =~ oid }
      end

      def sync(entry)
        crd = Card.new(entry, self)
        crd = crd.read_or_setup
        cards.push(crd)
        self
      end

      def create
        unless exist?
          Ha2itat.log("deck: creating #{name}")
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
        @cards
      end
      
    end
  end
end
