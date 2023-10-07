module Ha2itat::Slices
  module Bagpipe
    module Actions
      class Index < Action
        include Ha2itat.h(:pager)

        def handle(req, res)
          bagpipe = adapter.read(params_path(req.params))
          res.render(view, bagpipe: bagpipe)
        end
      end
    end
  end
end
