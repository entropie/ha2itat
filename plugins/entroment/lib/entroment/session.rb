module Plugins
  module Entroment

    class Sessions < Array
     def self.yaml_load(file:)
        Psych.unsafe_load(::File.readlines(file).join)
      end

      def self.load(deck)
        session_list = Dir.glob("%s/sessions/*.yaml"  % deck.path).map do |deckfile|
          yaml_load(file: deckfile)
        end
        ret = new.push(*session_list)
      end

      def [](sid)
        select{ |sl| sl.id == sid }.shift
      end
    end

    class SessionLog < Array
    end

    class Session
      attr_reader :deck, :created_at, :updated_at, :log

      SettingsHash = {
        length: 20
      }

      attr_reader *SettingsHash.keys

      def initialize(deck, **options)
        @deck = deck
        @user_id = deck.user.id
        @deckname = deck.name
        @session_id = Ha2itat::Database::get_random_id(8)

        @created_at = Time.now
        @updated_at = Time.now
        @log = SessionLog.new

        SettingsHash.merge(options).each_pair do |optn, optv|
          instance_variable_set("@%s" % optn, optv)
        end
      end

      def start
        write
        self
      end

      def id
        @session_id
      end

      def cardids
        @cardids ||= []
      end

      def cards
        @cards = cardids.map{ |cid| deck.cards[cid] }
      end

      def deck
        @deck ||=
          begin
            adapter_user = Ha2itat.adapter(:user).by_id(@user_id)
            Ha2itat.adapter(:entroment).with_user(adapter_user){ |a| a.decks[@deckname] }
          end
      end

      def deal!
        card_to_deal = cards.shift
        cardid = @cardids.shift
        card_to_deal
        
      end

      def add(*cards)
        cards.each do |cardtoadd|
          next if cardids.size >= length
          cardids.push(cardtoadd.id)
        end
        self
      end

      def filename
        "%s-%s.yaml" % [created_at.strftime("%y-%m-%d"), id]
      end

      def path
        ::File.join(deck.path, "sessions")
      end

      def file
        ::File.join(path, filename)
      end

      def prepare_for_save
        cardids
        remove_instance_variable("@deck")
        self
      end

      def to_yaml
        foryaml = prepare_for_save.dup
        YAML::dump(foryaml)
      end

      def write
        sessiondir = path
        ::FileUtils.mkdir_p(sessiondir, verbose: true) unless ::File.exist?(sessiondir)
        Ha2itat.log("session: #{id} write #{file}")
        @updated_at = Time.now
        ::File.open(file, "w+"){ |fp| fp.puts(to_yaml) }
      end

      def transaction(&blk)
        raise "no block given" unless block_given?
        yield self
        # fy = to_yaml
        # p filename
        # puts fy
        # # p file
        # exit
      end
    end
  end
end
