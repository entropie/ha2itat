require_relative "../creator"

module Ha2itat
  module CLI
    module Commands

      class App < Dry::CLI::Command
        desc "generates app"

        argument :name, type: :string,  required: true, desc: "Optional directories"
        
        def call(name:, **options)
          Ha2itat::Creator::App.new(name).do_create
        end
      end
    end
  end
end


