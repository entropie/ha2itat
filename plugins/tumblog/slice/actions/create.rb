module Ha2itat::Slices
  module Tumblog
    module Actions
      class Create < Action


        params do
          required(:content).filled(:string)
          optional(:title).value(:string)
          optional(:tags).value(:string)
          optional(:token).value(:string)
          optional(:edit).value(:string)
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

            redirect_target = req.params[:edit] ? :backend_tumblog_edit : :backend_tumblog_show
            res.redirect_to path(redirect_target, id: post.id)
          end
        end

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
