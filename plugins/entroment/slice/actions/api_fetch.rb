module Ha2itat::Slices
  module Entroment
    module Actions
      class APIFetch < Action

        def handle(req, res)
          res.format = :json
          entries = []
          if rid = req.params[:id]
            entries.push awu(req){ |adptr| adptr.by_id(rid) }
          else
            entries.push(*awu(req){ |adptr| adptr.entries })
          end
          res.body = entries.map{ |e| e.to_hash }.to_json
        end
      end
    end
  end
end
