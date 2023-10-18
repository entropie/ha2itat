module Ha2itat::Slices
  module Tumblog
    module Actions

      class Read < Hanami::Action
        include ActionMethodsCommon

        def handle(req, res)
          path = params_path(req.params).shift
          userid, postid, * = path.split("/")
          adptr = adapter(:tumblog).with_user(session_user(req))
          # unless adptr.user
          #   a = adapter(:tumblog).with_user( adapter(:user).by_id(userid))
          #   p a.by_id(postid)

          # end

          res.body = ::File.read(::File.join(adptr.datadir, path))
        end
      end
    end
  end
end
