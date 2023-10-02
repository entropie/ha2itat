module Ha2itat::Slices
  module Zettel
    module Actions
      class Upload < Action

        def handle(req, res)
          adptr = adapter.with_user(session_user(req))
          sheet = adptr.by_id(req.params[:id])
          ret = adptr.upload(sheet, req.params[:files])
          res.redirect_to(redirect_target_from_request(req) || path(:backend_zettel_show, id: sheet.id)) 
        end
      end
    end
  end
end                      
