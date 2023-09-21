require "hanami/action"

module Ha2itat::Slices
  module Snippet

    module Actions
      class Index < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          snippets = Ha2itat.adapter(:snippet).toplevel_snippets

          pager = Pager.new(req.params.to_hash, snippets)
          pager.link_proc = -> (n) { routes.path(:backend_snippet_index, page: n) }
          res.render(view, pager: pager)
        end
      end
    end

  end
end
