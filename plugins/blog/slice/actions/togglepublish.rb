module Ha2itat::Slices
  module Blog
    module Actions
      class Togglepublish < Action

        def handle(req, res)
          post = by_slug(req)
          return unless post
          if post.draft?
            p :draft
            adapter.to_post(post)

            # if Habitat.quart.plugins.enabled?(:vgwort)
            #   post_with_vgw = post.with_plugin(VGWort)
            #   if post_with_vgw.id_attached?
            #   else
            #     attach_id = post_with_vgw.attach_id
            #   end
            # end
          else
            p :published
            adapter.to_draft(post)
          end
          res.redirect_to(redirect_target_from_request(req) || path(:backend_blog_show, slug: post.slug))
        end
      end
    end
  end
end                      
