module Ha2itat::Slices
  module Tumblog
    module Actions
      class Index < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          posts = adapter.with_user(session_user(req)).entries.sort_by{|p| p.created_at }.reverse
          pager = Pager.new(req.params.to_hash, posts, 2)
          pager.link_proc = -> (n) { routes.path(:backend_tumblog_index, page: n) }
          res.render(view, pager: pager)
        end
      end
    end
  end
end                      
