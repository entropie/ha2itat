module Ha2itat::Slices
  module Entroment
    module Actions
      class Show < Action

        def handle(req, res)
          entry = awu(req){|adptr| adptr.by_id(req.params[:id]) }
          res.render(view, entry: entry)
        end
      end
    end
  end
end
