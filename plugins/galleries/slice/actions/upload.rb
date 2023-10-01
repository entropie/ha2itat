module Ha2itat::Slices
  module Galleries
    module Actions
      class Upload < Action

        params do
          required(:slug).filled(:string)
          required(:file)
          optional(:goto)
        end

        def handle(req, res)
          gallery = adapter.find_or_create(req.params[:slug])

          if req.post?
            begin
              files = req.params[:file]
              filesarr = files.map{ |f| f[:tempfile].path }
              adapter.transaction(gallery) do |g|
                g.add(filesarr)
              end
            rescue
            ensure
              res.redirect_to(redirect_target_from_request(req) || path(:backend_galleries_show, slug: gallery.ident))
            end
          end
        end
      end
    end
  end
end                      
