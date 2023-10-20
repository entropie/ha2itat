module Plugins

  module SimpleDB

    class Databases < Array
      def initialize(adapter)
        @adapter = adapter
      end

      def [](obj)
        select{ |e| e =~ obj }.first
      end

    end

    def self.databases
      @databases ||= Databases.new(Ha2itat.adapter(:simpledb))
    end

    def self.clear
      @databases = nil
      databases
    end

    def self.read_from(adapter, what = "rb")
      Dir.glob("%s/*/*.%s" % [adapter.repository_path, what]).each do |dbfile|
        dbi = SimpleDB.load(dbfile)
        dbi.load_or_read
        databases << dbi
      end
    end

    def self.get_binding
      binding
    end

    def self.load(file)
      Ha2itat.log "simpledb:load #{file}"
      eval(File.readlines(file).join, SimpleDB.get_binding)
    end

    DEFAULT_ADAPTER = :File

    class DB

      def self.entries
        @entries ||= []
      end

      def self.load_or_run(file)
        SimpleDB.load_or_run
      end

      def self.path(*args)
        Ha2itat.adapter(:simpledb).repository_path(*args)
      end

      def self.=~(obj)
        name.to_s.split("::").last.downcase.to_sym == obj
      end

      def self.load_or_read
        if entries.empty?
          read
          Ha2itat.log "simpledb:read: #{ entries.size } entries"
        end
        entries
      end

    end
  end

end
