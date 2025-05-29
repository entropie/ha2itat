module Ha2itat::Slices
  module Tumblog
    module Actions

      class Read < Hanami::Action

        include ActionMethodsCommon

        before :check_token
        include Hanami::Action::Session

        def handle(req, res)
          path = params_path(req.params).shift

          userid, postid, * = path.split("/")
          adptr = Ha2itat.adapter(:tumblog).with_user(session_user(req))

          target_filename = ::File.join(adptr.datadir, path)

          mime = MIME::Types.type_for(target_filename).first&.content_type || 'application/octet-stream'
          file = File.open(target_filename, 'rb')

          res.format = mime
          res.body = ::File.read(target_filename)
        end
      end
    end
  end
end
