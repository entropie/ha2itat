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
        ret = new.push(*session_list.sort_by{ |s| s.created_at }.reverse)
      end

      def [](sid)
        select{ |sl| sl.id == sid }.shift
      end
    end

    class SessionLog < Array
      def card_already_rated?(cardid)
        any?{ |logentry| logentry.cardid == cardid}
      end
    end

    class Session
      attr_reader :deck, :created_at, :log
      attr_accessor :updated_at

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

      def user
        Ha2itat.adapter(:user).by_id(@user_id)
      end

      def cardids
        @cardids ||= []
      end

      def done_count
        log.size
      end

      def remaining_count
        cardids.size
      end

      def total_count
        remaining_count + done_count
      end

      def due_left?
        not @cardids.empty?
      end

      def cards
        @cards = cardids.map{ |cid| deck.cards[cid] }
      end

      def deck
        @deck ||=
          begin
            Ha2itat.adapter(:entroment).with_user(user){ |a| a.decks[@deckname] }
          end
      end

      def deal!
        card_to_deal = cards.shift
        cardid = @cardids.shift
        card_to_deal
      end

      def session_score
        answered_count = total_count - remaining_count
        return 0 if answered_count.zero?

        accuracy = correct_count.to_f / answered_count
        progress = answered_count.to_f / total_count
        score = 5 * accuracy * progress
        score.round(2)
      end

      def add(*cards)
        cards.each do |cardtoadd|
          next if cardids.size >= length
          cardids.push(cardtoadd.id)
        end
        self
      end

      def handle_rated_card(card, resulthash)
        if resulthash[:rating] < 3
          if log.card_already_rated?(resulthash[:cardid])
            Ha2itat.log("session: card rating < 3, but already appended once this session: skip")
          else
            Ha2itat.log("session: card rating < 3, appending to current session")
            cardids.append(resulthash[:cardid])
          end
        end
      end

      def rate(card, rating)
        resulthash = card.rate(rating)
        handle_rated_card(card, resulthash)
        log_rating(**resulthash)
        resulthash
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
        remove_instance_variable("@cards") rescue nil
        remove_instance_variable("@deck") rescue nil

        SettingsHash.each_pair do |optn, optv|
          remove_instance_variable("@%s" % optn) rescue nil
        end
        self
      end

      def to_yaml
        foryaml = prepare_for_save.dup
        YAML::dump(foryaml)
      end

      def verbose_link(url:)
        cls = due_left? ? "unfinished" : "finished"
        short_stats = "<span class='%s'>%s/%s</span>" % [cls, done_count, total_count]
        "<a href='%s'>%s</a> %s" % [url, created_at.strftime("%y%m-%d&mdash;%H:%M"), short_stats]
      end

      def write
        Ha2itat.adapter(:entroment).write_session(dup.prepare_for_save)
        self
      end

      def destroy
        Ha2itat.adapter(:entroment).destroy_session(self)
        self
      end

      def log_rating(**hash)
        @log.push(LogEntry.new(**hash))
      end

      def transaction(&blk)
        raise "no block given" unless block_given?
        begin
          yield self
        ensure
          write
        end
      end

      def report(&blk)
        result = []
        log.each do |logentry|
          card = deck.cards[logentry.cardid]
          pair = [card, logentry]
          result << pair
          yield *pair if block_given?
        end
        result
      end
    end
  end
end
