module Ha2itat::Slices
  module Tumblog
    module Actions
      class Clytdlp < Action

        def handle(req, res)
          params = req.params.to_hash
          content, tags = params[:content], params[:tags]
          p content, tags
          # res.render(view)
        end
      end
    end
  end
end
