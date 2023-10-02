module Ha2itat::Slices
  module Zettel
    module Actions
      class Create < Action

        def handle(req, res)
          sheet = adapter.with_user(session_user(req)).update_or_create(req.params.to_hash)
          if req.post? and sheet.valid?
            adapter.store(sheet)
          end
          res.render(view, sheet: sheet)
        end
      end
    end
  end
end                      
