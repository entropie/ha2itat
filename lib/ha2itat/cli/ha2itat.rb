require_relative "../creator"

module Ha2itat
  module CLI
    module Commands

      class App < Dry::CLI::Command
        desc "generates app"


        argument :name, type: :string,  required: true, desc: "name"
        argument :git, type: :string,   required: false, desc: "initialize git repositories on the server (does not create app)"

        def call(name:, git: nil, **options)
          Ha2itat::Creator.
            set_environment(media_dir: "~/Data/quarters/newmedia",
                            source_dir: "~/Source/quarters/")

          creator = Ha2itat::Creator::App.new(name)
          if git
            raise "no hostname(H2_HOSTNAME) provided; exiting" unless ENV["H2_HOSTNAME"]
            creator.do_create_app
            creator.do_git
          else
            creator.do_create_app
          end
        end
      end
    end
  end
end
