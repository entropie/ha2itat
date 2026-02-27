module Ha2itat::Slices
  module Polygram
    module Actions
      class Create < Action

        def handle(req, res)
          caze = nil

          if req.post?
            caze = adapter.create(user_id: session_user(req).id)

            req.params[:file].each do |userfile|
              adapter.upload_for(caze, path: userfile[:tempfile].path)
            end
          end

          res.render(view, caze: nil)
        end
      end
    end
  end
end
