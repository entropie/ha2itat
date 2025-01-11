module Plugins
  module Entroment

    class Cards < Array; end
    
    class Card
      include EntromentAdapter

      attr_reader :entry, :deck

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

        [:entry, :deck, :user].each{ |iv|
          remove_instance_variable("@#{iv}") rescue nil
        }

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
