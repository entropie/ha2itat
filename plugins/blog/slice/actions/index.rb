module Ha2itat::Slices
  module Blog
    module Actions
      class Index < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          usr = session_user(req)
          posts = adapter.with_user(usr).posts.sort_by {|p| p.created_at }.reverse
          pager = Pager.new(req.params.to_hash, posts)

          if pager.current_items.size == 0 and pager.current_page > 1
            res.redirect_to(path(:backend_blog_index, page: "last"))
          end

          pager.link_proc = -> (n) { routes.path(:backend_blog_index, page: n) }
          res.render(view, pager: pager)
        end
      end
    end
  end
end
