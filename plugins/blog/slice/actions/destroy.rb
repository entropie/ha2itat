module Ha2itat::Slices
  module Blog
    module Actions
      class Destroy < Action

        params do
          required(:slug).filled(:string)
        end

        def handle(req, res)
          raise "nah" unless req.params.valid?
          post = by_slug(req)
          adapter.destroy(post, req.params[:lang])
          res.redirect_to path(:backend_blog_index)
        end
      end
    end
  end
end
