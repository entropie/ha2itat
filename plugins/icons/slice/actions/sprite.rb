module Ha2itat::Slices
  module Icons
    module Actions
      class Sprite < Hanami::Action # subclass Hanami::Action directly to bypass backend auth

        def handle(req, res)
          complete_file = Ha2itat.root.join("plugins/icons/assets/feather-sprite.svg")
          res.format = "image/svg+xml"
          res.cache_control :public, max_age: 60*60*24*32
          res.body = ::File.read(complete_file)
        end
      end
    end
  end
end
