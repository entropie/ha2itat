module Ha2itat::Slices::Entroment
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def adapter
      Ha2itat.adapter(:entroment)
    end

    def awu(req, &blk)
      adapter.with_user(session_user(req), &blk)
    end
    
    def by_id(req)
      awu(req){ |adptr| adptr.by_id(req.params[:id]) }
    end

    def tagify(strorarr)
      Plugins::Entroment.tagify(strorarr)
    end

    def create_or_edit_post(req, res)
      entry = by_id(req)
      if req.post?
        paramhash = req.params.to_hash

        tags = paramhash[:tags] = tagify(paramhash[:tags])

        entry =
          if not entry
            awu(req){ |adptr| adptr.create(content: req.params[:content], tags: tags) }
          else
            awu(req){ |adptr| adptr.update(entry, content: req.params[:content], tags: tags) }
          end
      end
      entry
    end

  end
end
