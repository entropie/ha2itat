module Ha2itat::Slices
  module Blog
    module Actions
      class Edit < Action

        params do
          required(:title).filled(:string)
          required(:tags).filled(:string)
          required(:content).filled(:string)
          required(:slug).filled(:string)
          optional(:image).value(:string)
        end


        def handle(req, res)
          post = create_or_edit_post(req, res)
          res.render(view, post: post)
        end
      end
    end
  end
end                      
