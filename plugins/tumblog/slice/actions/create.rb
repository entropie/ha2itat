module Ha2itat::Slices
  module Tumblog
    module Actions
      class Create < Action


        params do
          required(:content).filled(:string)
          optional(:title).value(:string)
          optional(:tags).value(:string)
        end
        

        def handle(req, res)

          if req.params.valid?
            content = req.params[:content]
            tags = Plugins::Tumblog.tagify(req.params[:tags])
            title = req.params[:title]

            post = adapter.create(:content => content, :tags => tags, :title => title)

            post.private!
            post.handler.process!
            adapter.with_user(session_user(req)).store(post)
            res.redirect_to path(:backend_tumblog_show, id: post.id)
          end
        end

        # def handle(req, res)
        #   ret = {}
        #   content = params[:s]
        #   adapter = Habitat.adapter(:tumblog).with_user(session_user)
      
        #   post = adapter.create(:content => content)

        #   if post.handler.create_interactive?
        #     urlwohttp = post.content.dup.gsub(/^https?:\/\//, "").gsub(/\/$/, "")
        #     post.update(content: "[%s](%s)" % [urlwohttp, post.content])
        #     post.private!
        #   end
      
        #   post.handler.process!
        #   adapter.store(post)

        #   if post.handler.create_interactive?
        #     redirect_to Backend.routes.tumblogEdit_path(post.id)
        #   end

        #   ret[:ok] = true
        #   self.body = ret.to_json

        #   # res.render(view)
        # end
      end
    end
  end
end                      
