module Ha2itat
  module CLI
    module Test
      class Run < Dry::CLI::Command
        desc "runs test(s)"

        argument :name, type: :string,  required: false, desc: "what test"

        def find_candiates(what)
          res = []
          if what
            Dir.glob("%s/#{what}/test.rb" % Ha2itat.root("plugins"))
          else
            Dir.glob("%s/*/test.rb" % Ha2itat.root("plugins"))            
          end
        end

        def call(name: nil, **options)
          name ||= :all
          name = name.to_sym
          candidates = find_candiates(name)
          raise "no candidates for #{name} found" if candidates.empty?

          candidates.each do |candidate|
            puts "testsuite for: %s" % candidate.split("/")[-2]
            torun = "ruby -r./lib/ha2itat/includes/ha2itat_test.rb #{candidate}"
            puts torun
            system(torun)

            #::FileUtils.rm_rf("/tmp/ha2itattest", verbose: true)
          end
          
          # require_relative Dir.pwd + "/config/app"
          # user = Ha2itat.adapter(:user).by_name(name)
          # route = Hanami.app.boot["routes"].path(route.to_sym)

          # raise "no user named `#{name}' found for `#{Ha2itat.quart.identifier}'" unless user
          # raise "no route named`#{name}' found for `#{Ha2itat.quart.identifier}'" unless route
          # puts
          # puts bookmarklet(goto) % [::File.join(Ha2itat.C(:host), route), user.token]
          p 1
        end
      end

    end
  end
end