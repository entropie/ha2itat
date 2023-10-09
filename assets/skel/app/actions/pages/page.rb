module %%Identifier%%
  module Actions
    module Pages
      class Page < %%Identifier%%::Action
        def handle(req, res)
          # response.body = self.class.name
          slug, frags = req.params[:slug], req.params[:fragments]

          snippet = Ha2itat.adapter(:snippets).page(slug, [frags].flatten, req.params)

          res.render(view, snippet: snippet)
        end
      end
    end
  end
end
