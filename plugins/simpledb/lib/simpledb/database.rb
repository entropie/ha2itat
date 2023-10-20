module Plugins

  module SimpleDB

    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    module Database
      extend Ha2itat::Database


      class Adapter
        class File < Ha2itat::Database::Adapter
          def initialize(path)
            @path = path
          end

          def read!
            Plugins::SimpleDB.read_from(self)
            true
          end

          def repository_path(*args)
            ::File.join(@path, "db", *args)
          end

          def [](what)
            SimpleDB.databases[what]
          end

          def to_a
            SimpleDB.databases
          end
        end
      end

    end
  end
end
