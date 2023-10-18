module Ha2itat::Slices
  module Tumblog
    module Actions
      class Read < Action

        def handle(req, res)
          path = params_path(req.params)
          adptr = adapter.with_user(session_user(req))
          res.body = ::File.read(::File.join(adptr.datadir, path))
        end
      end
    end
  end
end
