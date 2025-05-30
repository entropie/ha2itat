module ViewMethodsCommon

  def snip(what)
    snippet = Ha2itat.adapter(:snippets).select(what)
    snippet.render(self)
  end

  def rsnip(what, locale = nil)
    locale ||= session[:locale]
    locale_snip = "%s-%s" % [locale, what.to_s]
    if locale == Ha2itat.C(:default_locale)
      Ha2itat.debug "snippets(%s): requested locale(%s) == default_locale(%s)" % [what, locale, Ha2itat.C(:default_locale)]
      return snip(what)
    end

    snippet = Ha2itat.adapter(:snippets).select(locale_snip)
    unless snippet.kind_of?(Plugins::Snippets::NotExistingSnippet)
      snippet.render(self)
    else
      Ha2itat.log "rsnip `%s' requested but does not exist" % locale_snip
      snip(what)
    end
  end

end

module Plugins

  module Snippets

    DEFAULT_ADAPTER = :File

    def self.all
      Ha2itat.adapter(:snippets).snippets
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
        ret = Ha2itat::Renderer.render(:markdown, to_s, env: env)
        if ret =~ /^<p/
          return ret[3..-6]
        end
        ret
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
        Ha2itat::Renderer.render(:haml, to_s, env: env)
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
