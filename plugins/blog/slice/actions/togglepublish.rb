module Ha2itat::Slices
  module Blog
    module Actions
      class Togglepublish < Action

        def handle(req, res)
          post = by_slug(req)
          return unless post
          if post.draft?
            post = adapter.to_post(post)
            post.try_vgwort_attach
          else
            adapter.to_draft(post)
          end
          res.redirect_to(redirect_target_from_request(req) || path(:backend_blog_show, slug: post.slug))
        end
      end
    end
  end
end
