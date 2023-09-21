module Ha2itat::Slices
  module User
    module Actions
      class Login < Action

        def handle(req, res)
          res.render(view)
        end
      end
    end
  end
end                      
