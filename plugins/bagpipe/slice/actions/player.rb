module Ha2itat::Slices
  module Bagpipe
    module Actions
      class Player < Action

        def handle(req, res)
          bagpipe = adapter.read(params_path(req.params))
          # p 1
          # p bagpipe.parent.class
          res.render(view, bagpipe: bagpipe)
        end
      end
    end
  end
end
