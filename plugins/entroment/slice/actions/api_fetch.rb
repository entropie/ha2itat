module Ha2itat::Slices
  module Entroment
    module Actions
      class APIFetch < Action

        def handle(req, res)
          res.format = :json
          entries = []
          tags = tagify(req.params[:tags])
          if rid = req.params[:id]
            entries.push(*awu(req){ |adptr| adptr.by_id(rid) })
          elsif !tags.empty?
            entries.push *awu(req){ |adptr| adptr.by_tags(*tags) }
          else
            entries.push *awu(req){ |adptr| adptr.entries }
          end
          res.body = entries.sort_by{ |e| e.updated_at }.reverse.map{ |e| e.to_hash }.to_json
        end
      end
    end
  end
end
