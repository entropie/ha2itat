module Ha2itat::Slices
  module Entroment
    module Actions
      class Destroy < Action

        def handle(req, res)
          awu(req){|adptr|
            entry = adptr.by_id(req.params[:id])
            adptr.destroy(entry)
          }
          res.redirect_to(redirect_target_from_request(req) || path(:backend_entroment_index))
        end
      end
    end
  end
end
