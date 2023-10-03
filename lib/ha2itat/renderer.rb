require "commonmarker"
require "haml"

module Ha2itat
  module Renderer

    def render(kind, content, env: proc{})
      case kind

      when :haml
        haml_renderer = Haml::Template.new(escape_html: false) { content }
        haml_renderer.render(env)

      when :markdown
        doc = CommonMarker.render_doc(content, [:STRIKETHROUGH_DOUBLE_TILDE, :FOOTNOTES, :UNSAFE])
        markdown_renderer = CommonMarker::HtmlRenderer.new(options: [:UNSAFE])
        markdown_renderer.render(doc)
      end
    end

    module_function :render
  end
end
