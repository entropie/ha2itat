module Ha2itat::Slices
  module Zettel
    module Actions
      class Edit < Action

        def handle(req, res)
          sheet = adapter.with_user(session_user(req)).by_id(req.params[:id])

          if req.post?
            sheet = adapter.update_or_create(req.params)
            adapter.store(sheet)
            res.redirect_to(path(:backend_zettel_show, id: sheet.id))
          end

          res.render(view, sheet: sheet)
        end
      end
    end
  end
end                      
