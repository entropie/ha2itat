module Plugins
  module Entroment

    class LogEntry

      LogFields = [:easiness_factor, :repetition_count, :correct_count, :incorrect_count, :interval, :rating, :cardid]
      attr_reader *LogFields

      alias :rated :rating
      def initialize(**hash)
        @date = Time.now
        LogFields.each do |lf|
          instance_variable_set("@%s" % lf, hash[lf])
        end
      end

      def last_reviewed
        @date
      end

    end
    
    module EntromentAdapter
      def adapter(&blk)
        Ha2itat.adapter(:entroment).dup.with_user(user, &blk)
      end
    end

    def self.tagify(strorarr)
      return [] unless strorarr
      if strorarr.kind_of?(Array)
        return strorarr
      else
        strorarr.split(",").map{ |e| e.strip }.compact
      end
    end

  end
end
