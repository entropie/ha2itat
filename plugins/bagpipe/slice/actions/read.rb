module Ha2itat::Slices
  module Bagpipe
    module Actions
      class Read < Action

        def handle(req, res)
          bagpipe = adapter.read(params_path(req.params))

          unless bagpipe&.song? && File.exist?(bagpipe.path)
            res.status = 404
            res.body = "Song not found"
            return
          end

          mime_type = MIME::Types.type_for(bagpipe.path).first&.content_type || 'application/octet-stream'
          # res.env['CONTENT_TYPE'] = mime_type
          res.format = mime_type
          res.unsafe_send_file(bagpipe.path)
        end
      end
    end
  end
end
