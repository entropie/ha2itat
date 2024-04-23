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


        def convert_input_url(content)
          urlwohttp = content.dup.gsub(/^https?:\/\//, "").gsub(/\/$/, "").gsub(/^www\./, "")
          "[%s](%s)" % [urlwohttp, content]
        end

        def handle(req, res)
          if req.params.valid?
            content = req.params[:content]
            tags = Plugins::Tumblog.tagify(req.params[:tags])
            title = req.params[:title]

            post = adapter.with_user(session_user(req)).create(content: content, tags: tags, title: title)

            redirect_target = :backend_tumblog_show

            if req.params[:edit] or post.handler.create_interactive?
              redirect_target = :backend_tumblog_edit
              post.private!
              post.update(content: convert_input_url(post.content))
            end

            begin
              post.handler.process!
            rescue Plugins::Tumblog::SkipForYTDLPClientVersion
              res.redirect_to path(:backend_tumblog_clytdlp, { content:, tags:, title: })
            rescue
              pp $!
            end

            adapter.with_user(session_user(req)).store(post)

            res.redirect_to path(redirect_target, id: post.id)
          end
        end
      end
    end
  end
end
