module Plugins
  module Entroment

    class Cards < Array
      def by_due
        sort_by { |card| card.due_delta(Time.now)}
      end

      def [](obj)
        select{ |c| c =~ obj }.shift
      end
    end
    
    class Card
      include EntromentAdapter

      attr_reader :entry, :deck
      attr_accessor :logsize

      DefaultLogSize = 10

      RatingMax = 5

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
        @log = []
      end

      def id
        @entry_id
      end

      def =~(other)
        if other.kind_of?(String)
          @entry_id == other
        end
      end

      def logsize
        @logsize || DefaultLogSize
      end

      def entry
        @entry ||= adapter{ |adptr| adptr.by_id(@entry_id) }
      end

      def user
        @user ||= Ha2itat.adapter(:user).by_id(@user_id)
      end

      def deck
        @deck ||= adapter{ |adptr| adptr.decks[@deckname] }
      end

      def hash_to_instance_variables(hash)
        hash.each_pair{ |h,k|
          instance_variable_set("@%s" % h, k)
        }
      end

      def prepare_for_save
        @deckname = deck.name
        @user_id = entry.user.id

        [:entry, :deck, :user, :logsize].each{ |iv|
          remove_instance_variable("@#{iv}") rescue nil
        }
        self
      end

      def next_due_time
        @last_reviewed + @interval * 24 * 3600
      end

      def due_delta(ftime)
        ((next_due_time - ftime) / 3600).to_i
      end
      
      def write
        towrite = prepare_for_save.dup
        Ha2itat.adapter(:entroment).write_card(towrite)
        self
      end

      def calculate_easing(rating, old_easing)
        rating_max = RatingMax
        [1.3, old_easing + (0.1 - (rating_max - rating) * (0.08 + (rating_max - rating) * 0.02))].max.round(1)
      end

      def rate(rating)
        @easiness_factor = calculate_easing(rating, @easiness_factor)

        if rating >= 3
          @repetition_count += 1
          @correct_count += 1
          @interval =
            case @repetition_count
            when 1 then 1
            when 2 then 6
            else (@interval * @easiness_factor).round
            end
        else
          @incorrect_count += 1
          @repetition_count = 0
          @interval = 1
        end

        @last_reviewed = Time.now

        log_hash = {
          repetition_count: @repetition_count,
          incorrect_count: @incorrect_count,
          correct_count: @correct_count,
          interval: @interval,
          easiness_factor: @easiness_factor,
          rating: rating}
        Ha2itat.log("card:rate #{id}:#{deck.name}: #{PP.pp(log_hash, "").gsub("\n", "")}")

        log_rating(**log_hash)
        write
        log_hash.merge(cardid: id)
      end

      def truncate_log!
        @log = @log.last(logsize)
      end

      def log_rating(**hash)
        @log.push(LogEntry.new(**hash))
        truncate_log!
      end

      def path
        ::File.join(deck.path, "card-%s" % ::File.basename(entry.filename))
      end

      def exist?
        ::File.exist?(path)
      end

      def destroy
        Ha2itat.log("deck(#{@deckname}): removing card for \##{@entry_id}")
        ::FileUtils.rm_rf(path, verbose: true)
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
  end
end
