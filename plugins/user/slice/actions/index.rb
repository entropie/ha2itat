require "hanami/action"

module Ha2itat::Slices
  module User
    module Actions
      class Index < Action

        include Ha2itat.h(:pager)

        def handle(req, res)
          pager = Pager.new(req.params.to_hash, adapter(:user).user)
          pager.link_proc = -> (n) { routes.path(:backend_user_index, page: n) }
          res.render(view, pager: pager)
        end
      end
    end

  end
end
