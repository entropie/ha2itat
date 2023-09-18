require "hanami/action"

module Ha2itat::Slices
  module User

    module Actions
      class Test < Action

        def handle(req, res)
          p r=Ha2itat.adapter(:user)
          Ha2itat.log "deine mama"
          create({ :password => "moep187", :name => "Michael Trommer", :email => "mictro@gmail.com" })
          res.render(view)
        end

        def create(params)
          user = Plugins::User::User.new.populate(params)
          Ha2itat.adapter(:user).store(user)
        end
      end
    end

  end
end
