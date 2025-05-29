module Ha2itat::Slices::Tumblog
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))

    def by_id(req)
      adapter.with_user(session_user(req)).by_id(req.params[:id])
    end

    def adapter
      Ha2itat.adapter(:tumblog)
    end
  end
end
