module Ha2itat::Slices
  module Bagpipe
    module Actions
      class Play < Action

        def handle(req, res)
          bagpipe = adapter.read(params_path(req.params))
          if bagpipe.song?
            res.env["CONTENT_TYPE"] = "audio/mpeg3"
            res.body = bagpipe.to_pls(req.params.env)
            res.format = "audio/x-scpls"
          else
            res.format = "audio/x-scpls"
            res.body = bagpipe.parent.to_pls(req.params.env)
          end
          # res.render(view)
        end
      end
    end
  end
end
