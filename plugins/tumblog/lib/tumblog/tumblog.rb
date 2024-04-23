require_relative "database"
require_relative "post"
require_relative "api"

module Plugins
  module Tumblog

    class SkipForYTDLPClientVersion < StandardError

    end

    DEFAULT_ADAPTER = :File

    def self.token=(tknstr)
      @token = tknstr.strip
    end

    def self.token
      @token
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
