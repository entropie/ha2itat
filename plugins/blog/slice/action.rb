module Ha2itat::Slices::Blog
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def by_slug(req)
      adapter.with_user(session_user(req)).by_slug(req.params[:slug])
    end
    
    def create_or_edit_post(req, res)
      post = by_slug(req)
      if req.post?
        params = req.params.to_hash

        template = params[:template]
        if template and template.strip.empty?
          params.delete(:template)
          params[:template] = nil
        end

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
