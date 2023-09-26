module Ha2itat::Slices
  module Blog
    module Actions
      class Show < Action

        def handle(req, res)
          post = create_or_edit_post(req, res)
          res.render view, post: post
        end
      end
    end
  end
end                      
