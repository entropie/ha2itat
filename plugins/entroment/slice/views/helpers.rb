module Ha2itat::Slices

  module Entroment
    module Views
      module Helpers
        instance_eval(&Ha2itat::CD(:view))

        def html_link(card, deck, collapsed = false)
          nlink(path(:backend_entroment_card, cardid: card.id, name: deck.name, collapsed: collapsed), "<span class='l-pfx'>\#</span><code>#{card.id}</code>", "class": "cardid-link")
        end

        def session_html_progress(s)
          "(%s/%s)" % [s.remaining_count, s.total_count]
        end

      end
    end
  end
end
