module Ha2itat::Slices
  module Zettel
    module Actions
      class Edit < Action

        def handle(req, res)
          sheet = adapter.with_user(session_user(req)).by_id(req.params[:id])

          if req.post?
            sheet = adapter.update_or_create(req.params)
            adapter.store(sheet)
            res.redirect_to(redirect_target_from_request(req) || path(:backend_blog_index))
          end

          # if not sheet and potential_image = req.params[:id]
          #   p potential_image
          #   res.status = 400
          # else
          #   res.render(view, sheet: sheet)
          # end
          res.render(view, sheet: sheet)
        end
      end
    end
  end
end                      
