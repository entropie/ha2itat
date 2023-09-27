module ViewMethodsCommon

  def snip(what)
    snippet = Ha2itat.adapter(:snippets).select(what)
    snippet.render(self)
  end

end

module Plugins

  module Snippets

    DEFAULT_ADAPTER = :File

    def self.all
      Habitat.adapter(:snippets).snippets
    end

    module SnippetCreater
    end

    class Snippets < Array

      def initialize(arr)
        push(*arr)
      end

      def [](obj)
        ident = obj.to_sym
        ret = select{|s| s.ident == ident}
        return ret.first if ret
      end
    end

    class Snippet

      attr_reader :ident
      attr_accessor :path
      attr_accessor :env
      attr_accessor :content

      def initialize(ident)
        @ident = ident
      end

      def filename(ext)
        "%s.snippet.%s" % [ident, ext]
      end

      def self.ident_from(filename)
        filename.split(".").first.to_sym
      end

      def self.for(snippet_full_path)
        snippet_filename = File.basename(snippet_full_path)
        clz =
          if snippet_filename =~ /---/
            PageSnippet
          elsif snippet_filename =~ /\.haml$/
            HAMLSnippet
          else
            MarkdownSnippet
          end
        ret = clz.new(ident_from(snippet_filename))
        ret.path = snippet_full_path
        ret
      end

      def read
        @content = File.readlines(path).join
      end

      def content
        read
      end

      def to_s
        read
      end

      def exist?
        true
      end

      def css_class
        self.class.to_s.split("::").last.downcase
      end

      def page?
        false
      end

      def slug()= ident
    end

    class Env
      attr_reader :locals

      include ViewMethodsCommon

      def initialize
      end
    end


    class NotExistingSnippet < Snippet
      def read
        ""
      end

      def render(*args)
        "<span class='be-msg not-existing-snippet'>(Error:<strong>snippet</strong>: <code>#{ident}</code> not exist)</span>"
      end

      def exist?
        false
      end
    end
    
    class MarkdownSnippet < Snippet
      def filename
        super("markdown")
      end

      def render(env = nil)
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, footnotes: false)
        r = markdown.render(to_s)
      end

      def kind
        :markdown
      end

      def content_type
        "text/x-markdown"
      end
    end

    class HAMLSnippet < Snippet
      def filename
        super("haml")
      end

      def render(env = nil)
        env ||= Env.new
        haml_renderer = Haml::Template.new(escape_html: false) { to_s }
        "%s" % haml_renderer.render(env)
        # rescue
        # "<div class='warning'>nope: something went wrong while processing <code>#{ident}</code>: <code>#{$!.class}</code></div>"
      end

      def kind
        :haml
      end

      # for codemirror
      def content_type
        "text/x-haml"
      end
    end

    class PageSnippet < HAMLSnippet
      def page?
        true
      end

      def filename
        super
      end

      def parent?
        ident.to_s.split("---").size == 2
      end

      def children
        if parent?
          @children ||= Ha2itat.adapter(:snippets).grep("#{ident}---")
        end
      end
    end

  end


end
