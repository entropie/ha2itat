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
          optional(:marked_text).value(:string)
        end


        def convert_input_url(content, description = nil)
          desc = content.dup.gsub(/^https?:\/\//, "").gsub(/\/$/, "").gsub(/^www\./, "")
          desc = description if description && !description.empty? 
          "[%s](%s)" % [desc, content]
        end

        def handle(req, res)
          if req.params.valid?
            content = req.params[:content]
            tags = Plugins::Tumblog.tagify(req.params[:tags])
            title = req.params[:title]
            marked_text = req.params[:marked_text]

            post = adapter.with_user(session_user(req)).create(content: content, tags: tags, title: title)

            redirect_target = :backend_tumblog_show

            if req.params[:edit] or post.handler.create_interactive?
              redirect_target = :backend_tumblog_edit
              post.private!
              post.update(content: convert_input_url(post.content, marked_text))
            end

            begin
              post.handler.process!
            rescue Plugins::Tumblog::SkipForYTDLPClientVersion
              res.redirect_to path(:backend_tumblog_clytdlp, { content:, tags:, title: })
            rescue Plugins::Tumblog::SkipForImgClientVersion
              res.redirect_to path(:backend_tumblog_climgdl, { content:, tags:, title: })
            # rescue
            #   pp $!
            end

            adapter.with_user(session_user(req)).store(post)

            res.redirect_to path(redirect_target, id: post.id)
          end
        end
      end
    end
  end
end
