module Ha2itat::Slices
  module Blog
    module Actions
      class Create < Action

        params do
          required(:title).filled(:string)
          required(:tags).filled(:string)
          required(:content).filled(:string)
          optional(:slug).value(:string)
          optional(:image).value(:string)
        end

        def handle(req, res)
          # from ../action.rb
          create_or_edit_post(req, res)
        end
      end
    end
  end
end                      
