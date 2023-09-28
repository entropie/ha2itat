module Ha2itat::Slices
  module Galleries
    module Actions
      class Upload < Action

        params do
          required(:slug).filled(:string)
          required(:file)
        end

        def handle(req, res)
          gallery = adapter.find_or_create(req.params[:slug])

          if req.post?
            files = req.params[:file]
            filesarr = files.map{ |f| f[:tempfile].path }
            adapter.transaction(gallery) do |g|
              g.add(filesarr)
            end
            res.redirect_to path(:backend_galleries_show, slug: gallery.ident)
          end

        end
      end
    end
  end
end                      
