module Ha2itat::Slices
  module Blog
    module Actions
      class Withoutlayout < Action

        def handle(req, res)
          post = by_slug(req)
          template = req.params[:t] || post.template || Ha2itat.C(:default_template) || "fallback"
          post_template = post.with_template(template).compile(req.params.to_hash)
          res.render(view, post_template: post_template, post: post)
        end
      end
    end
  end
end
