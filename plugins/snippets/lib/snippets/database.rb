module Plugins

  module Snippets


    def self.get_default_adapter_initialized
      Database::Adapter.const_get(Ha2itat.default_adapter).new(Ha2itat.media_path)
    end

    DEFAULT_SNIPPET_TYPE = :markdown

    module Database

      extend Ha2itat::Database

      class Adapter

        class File < Ha2itat::Database::Adapter

          include Ha2itat::Mixins::FU

          SNIPPET_EXTENSION = ".snippet."

          def initialize(path)
            @path = path
          end

          def path(*args)
            ::File.join(@path, *args)
          end

          def class_for(kind)
            case kind.to_sym
            when :markdown then MarkdownSnippet
            when :haml then HAMLSnippet
            end
          end

          def adapter_class(kind = DEFAULT_SNIPPET_TYPE)
            class_for(kind)
          end

          def setup
            @setup = true
            log :debug, "setting up adapter directory #{path}"
            FileUtils.mkdir_p(path)
            @setup
          end

          def repository_path(*args)
            ::File.join(::File.realpath(path), "snippets", *args)
          rescue Errno::ENOENT
            warn "does not exist: #{path("blog")}"
            path("snippets", *args)
          end

          def snippet_filename(ident = nil)
            repository_path("%s%s" % [ident || ident, SNIPPET_EXTENSION])
          end

          def exist?(post)
            ::File.exist?(post_filename(post))
          end

          def datadir(*args)
            ::File.expand_path(repository_path("../data", *args))
          end

          def snippet_files
            toglob = repository_path + "/*" + SNIPPET_EXTENSION + "*"
            Dir.glob(toglob)
          end

          def grep(obj)
            str = obj.to_s
            snippets.select{|s| s.ident.to_s.include?(str) }
          end

          def select(obj, env = nil)
            ident = obj.to_sym
            ret = snippets[ident]
            unless ret
              return NotExistingSnippet.new(ident)
            end
            ret.env = env
            ret
          end

          def toplevel_snippets
            snippets.select{ |s|
              if s.page?
                s.parent?
              else
                true
              end
            }
          end

          def page(obj, sub = [], env = nil)
            subpages = ""

            sub = [sub].flatten.compact.map{|s| s.split("/")}.flatten

            subpages = sub.map{|sp| "---#{sp}" unless sp.to_s.empty? }
            ident = "page---#{obj}#{subpages.join}"
            r = select(ident, env)
            r
          end

          def exist?(obj)
            not select(obj).kind_of?(NotExistingSnippet)
          end

          def snippets
            Snippets.new(snippet_files.map{|sf| Snippet.for(sf) })
          end


          def load_file(yamlfile)
            log "loading #{Habitat.S(yamlfile)}"
            YAML::load_file(yamlfile)
          end

          def create(ident, content, kind = DEFAULT_SNIPPET_TYPE)
            snippet = adapter_class(kind).new(ident).extend(SnippetCreater)
            store(snippet, content)
            snippet
          end

          def update_or_create(ident, content, kind = DEFAULT_SNIPPET_TYPE)
            snippet = adapter_class(kind).new(ident).extend(SnippetCreater)
            store(snippet, content)
          end

          def store(snippet, content)
            log "snippet:STORE:#{snippet.ident}"
            file = repository_path(snippet.filename)
            FileUtils.mkdir_p(::File.dirname(file), :verbose => true) unless ::File.dirname(file)
            write(file, content)
          end

          def destroy(snippet)
            log "snippet:REMOVE:#{snippet.ident}"
            rm(repository_path(snippet.filename), :verbose => true)
          end
        end

      end

    end

  end
end
