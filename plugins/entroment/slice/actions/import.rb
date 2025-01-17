require "csv"
module Ha2itat::Slices
  module Entroment
    module Actions
      class Import < Action

        params do
          required(:name).filled(:string)
          optional(:text).filled(:string)
        end

        def handle(req, res)
          deck = awu(res) { |adptr| adptr.decks[req.params[:name]] }
          if req.post?
            text = req.params[:text]
            csv = CSV.new(text)
            csv.each do |a,b|
              entry = awu(req){ |adapter| adapter.create(tags: ["deck:#{deck.name}"], content: [a, "---", b].join("\n")) }
            end
          end
          res.render(view, deck: deck,  name: deck.name)
        end
      end
    end
  end
end
