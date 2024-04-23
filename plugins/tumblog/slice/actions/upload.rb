module Ha2itat::Slices
  module Tumblog
    module Actions
      class Upload < Action

        def handle(req, res)
          raise unless req.post?
          content = req.params[:content]
          tags = Plugins::Tumblog.tagify(req.params[:tags])

          tmpfile = req.params[:file][:tempfile]


          ext = URI(req.params[:media_url]).path.split(".").last

          post = adapter.with_user(session_user(req)).create(content: content, tags: tags, title: "")

          target_file = post.handler.target_media_file(post.id + "." + ext)

          Ha2itat.log "tumblog:upload: #{post.id} #{post.content} #{target_file}"
          ::FileUtils.mkdir_p(::File.dirname(target_file), verbose: true)
          ::FileUtils.cp(tmpfile.path, target_file, verbose: true)

          adapter.with_user(session_user(req)).store(post)

          res.body = {success: true, url: path(:backend_tumblog_show, id: post.id) }.to_json
        end
      end
    end
  end
end
