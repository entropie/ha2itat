module Ha2itat
  module CLI
    module Tools
      class Bookmarklet < Dry::CLI::Command
        desc "generate bookmarklate"

        argument :name, type: :string,  required: true, desc: "username"
        argument :route, type: :string,  required: true, desc: "internal route"
        argument :goto, type: :string,  required: false, desc: "goto after"

        def bookmarklet(goto = nil)
          gotostr = ""
          if goto
            gotostr = "&goto=#{goto}"
          end
          %Q|javascript:(function(){var url=encodeURI(document.location.href),endp="%s",token="%s";document.location.href=endp+"?token="+token+"#{gotostr}&content="+url;}());|
        end

        def call(name:, route:, goto: nil, **options)
          require_relative Dir.pwd + "/config/app"
          user = Ha2itat.adapter(:user).by_name(name)
          route = Hanami.app.boot["routes"].path(route.to_sym)

          raise "no user named `#{name}' found for `#{Ha2itat.quart.identifier}'" unless user
          raise "no route named`#{name}' found for `#{Ha2itat.quart.identifier}'" unless route
          puts
          puts bookmarklet(goto) % [::File.join(Ha2itat.C(:host), route), user.token]
        end
      end

      class TokenURL < Dry::CLI::Command
        desc "generate bookmarklate"

        argument :name, type: :string,  required: true, desc: "username"
        argument :route, type: :string,  required: true, desc: "internal route"
        argument :goto, type: :string,  required: false, desc: "goto after"

        def bookmarklet
          "%s?token=%s"
        end

        def call(name:, route:, goto: nil, **options)
          require_relative Dir.pwd + "/config/app"
          user = Ha2itat.adapter(:user).by_name(name)
          route = Hanami.app.boot["routes"].path(route.to_sym)

          raise "no user named `#{name}' found for `#{Ha2itat.quart.identifier}'" unless user
          raise "no route named`#{name}' found for `#{Ha2itat.quart.identifier}'" unless route
          ret = bookmarklet % [::File.join(Ha2itat.C(:host), route), user.token]
          if goto
            ret += "&goto=#{goto}"
          end
          puts ret
        end
      end

    end
  end
end
