module Plugins
  module Entroment

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
