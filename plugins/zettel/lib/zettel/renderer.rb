module Plugins
  module Zettel

    module Renderer

      class BaseRenderer
        attr_reader :sheet
        attr_reader :result

        def initialize(sheet)
          @sheet = sheet
        end

        def snippet_renderera
          [ Snippets::SheetReference ]
        end

        def content
          @sheet.content.dup
        end

        def render(renderer = snippet_renderer)
          Zettel.log "starting rendering #{PP.pp(renderer, "")}"
          @result = @sheet.content.dup
          renderer.each do |snippet|
            @result = snippet.new(content).render
          end
          @result
        end
      end


      class HTML < BaseRenderer
      end
    end
  end
end
