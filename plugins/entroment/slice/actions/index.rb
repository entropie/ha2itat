module Ha2itat::Slices
  module Entroment
    module Actions
      class Index < Action

        def handle(req, res)
          res.redirect_to(path(:backend_entroment_decks))
          # res.render(view)
        end
      end
    end
  end
end
