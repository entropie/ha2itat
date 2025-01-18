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
        Commonmarker.to_html(content,
                             options: {
                               extension: { footnotes: true },
                               render: { hardbreaks: false, unsafe: true }})
      end
    end

    module_function :render

  end
end
