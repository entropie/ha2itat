module Ha2itat::Slices
  module Tumblog
    module Actions
      class Clytdlp < Action

        def handle(req, res)
          params = req.params.to_hash
          content, tags = params[:content], params[:tags]
          #res.render(view, content: content, tags: tags)
        end
      end
    end
  end
end
