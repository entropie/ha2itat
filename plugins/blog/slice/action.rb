module Ha2itat::Slices::Blog
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def create_or_edit_post(req, res)
      post = adapter.with_user(session_user(req)).by_slug(req.params[:slug])
      if req.post?
        params = req.params.to_hash

        pimg = params.delete(:image)
        post = adapter.update_or_create(params)

        if pimg
          adapter.upload(post, pimg[:tempfile])
        end
        adapter.with_user(session_user(req)).store(post)
        return post
      end
      post
    end

    def adapter
      Ha2itat.adapter(:blog)
    end
  end
end
