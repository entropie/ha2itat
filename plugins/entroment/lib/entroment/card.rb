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

      attr_accessor *SRFieldsDefaults.keys

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
        Ha2itat.log("entroment card:rate #{id}:#{deck.name}: #{PP.pp(log_hash, "").gsub("\n", "")}")

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
        adapter{ |adptr| adptr.remove_card(self) }
      end

      def yaml_load(file:)
        Psych.unsafe_load(::File.readlines(file).join)
      end

      def to_html(collapsed = false)
        entry.to_html(collapsed: collapsed)
      end

      def encouragements
        [
          "Nice!",
          "Good job!",
          "Keep it up!",
          "Solid effort!",
          "Not bad at all!",
          "Well played!",
          "Clean!",
          "You're getting there!",
          "That's the way!",
          "Smooth move!",
          "Big brain!",
          "You're on fire!",
          "Poggers!",
          "Mega streak!",
          "Insane!",
          "Absolute legend!",
          "God tier!",
          "Unstoppable!",
          "Omega Pog!",
          "Giga Chad vibes!"
        ]
      end

      def streaktext(repetition_count)
        encouragements[[repetition_count, encouragements.size].min - 1]
      end

      def html_stats(show_time: true)
        html_block = "<div class='card-stats'>%s%s</div>"
        numbers = "123"
        dateline   = "<div class='date-line'><time title='%s'>%s</time></div>" % [last_reviewed.to_human_time, RelativeTime.in_words(last_reviewed)]

        dateline = "" unless show_time

        total_count = correct_count+incorrect_count
        percent = ((correct_count.to_f/total_count) * 100).round(1)
        fields = {
          correct: correct_count,
          incorrect: incorrect_count,
          percent: percent.nan? ? 0 : percent,
          streak: repetition_count,
          total: total_count
        }
        fields = fields.sort_by{ |f,k| f.to_s}.map{ |f,k| '<span class="%s">%s</span>' % ["field-#{f}", k]}
        
        streaktxt = if repetition_count == 0 then "" else "<span class='streaktext sn-#{ [repetition_count, 20].min }'>#{streaktext(repetition_count)}</span> <small>(#{fields[3]})</small>" end

        statsline = "%s/%s/<strong>%s</strong> <small>(%s%%)</small> %s" % [fields[0], fields[1], fields[4], fields[2], streaktxt]
        statsline   = "<div class='stats-line'>%s</div>" % [statsline]

        html_block % [dateline, statsline]
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
