module Ha2itat::Slices
  module Bagpipe
    module Actions
      class Read < Action

        def handle(req, res)
          bagpipe = adapter.read(params_path(req.params))
          if bagpipe.song?
            res.body = ::File.read(bagpipe.path)
          else
            halt 302
          end
        end
      end
    end
  end
end
