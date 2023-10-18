module Ha2itat::Slices
  module Zettel
    module Actions
      class Read < Action

        def handle(req, res)
          adptr = adapter.with_user(session_user(req))
          ppath = params_path(req.params).shift
          sheet_id, target_filename = ppath.split("/")
          sheet = adapter.by_id(sheet_id)

          media = sheet.uploads.select{|su| su.filename == target_filename }.first
          format = target_filename.split(".").last.to_sym
          res.format = format
          res.body = ::File.read(media.path)
        end
      end
    end
  end
end
