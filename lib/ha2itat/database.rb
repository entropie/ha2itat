module Ha2itat

  module Database

    class DataBaseError < StandardError; end
    class NotImplemented < DataBaseError; end
    class NotAuthorized < DataBaseError; end
    class NoUserContext < NotAuthorized; end      

    class EntryNotValid < DataBaseError; end     

    DEFAULT_PERMITTED_CLASSES = []

    def self.get_random_id(chrs = 32)
      ary = [*'a'..'z', *'A'..'Z', *0..9].shuffle
      enum = ary.permutation(chrs)
      enum.next.join
    end

    def self.make_slug(str)
      str.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    class Adapter

      NOT_IMPLMENTED_MSG = "not implemented in parent class; use corresponding subclass instead".freeze

      attr_reader :user

      def log(w, msg)
        if Object.constants.include?(:Hanami)
          Hanami.log(w, msg)
        else
          puts ">>> #{msg}"
        end
      end

      def permitted_classes
        @permitted_classes || PERMITTED_CLASSES
      end

      def yaml_load(file:)
        raise "not file" unless file
        YAML::load_file(file, permitted_classes: permitted_classes)
      end
    
      def setup
        raise NotImplemented, NOT_IMPLMENTED_MSG
      end

      def query(*_)
        raise NotImplemented, NOT_IMPLMENTED_MSG
      end

      def upload(sheet, params)
        raise NotImplemented, NOT_IMPLMENTED_MSG        
      end

      def adapter_class
        raise "can only be called by subclass of Habitat::Database::Adapter"
      end

      def create(param_hash)
        adapter_class.populate(param_hash)
      end

      def without_user(&blk)
        bkup = @user; @user = nil
        yield self
        @user = bkup
      end
    end
  end
end
