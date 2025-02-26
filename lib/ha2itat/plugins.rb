module Ha2itat


  class Plugins < Array
    def initialize(quart)
      @quart = quart
    end

    def register(arg)
      plugin_dir = Ha2itat.plugin_root(arg.to_s)
      raise "not existing path `#{plugin_dir}'" unless ::File.directory?(plugin_dir)
      new_plugin = Plugin.new(arg.to_sym)
      Ha2itat.log("#{arg} #{new_plugin.class}")
      new_plugin.path = plugin_dir
      new_plugin.try_load
      new_plugin.try_adapter_file
      new_plugin.try_load_slice
      new_plugin.register_slice(Hanami.app)
      self << new_plugin
      self
    end

    def inspect
      "P(%s)" % map{ |plug| plug.name }.join(",")
    end

    def enabled?(wanted_plug)
      sym_plug = wanted_plug.to_sym
      any?{|plug| plug.name == sym_plug}
    end

    def transaction(&blk)
      yield self
    end

    def write_javascript_include_file!
      Plugins.write_javascript_include_file!
    end

    def interactive_plugins
      [:snippets, :galleries, :tumblog, :zettel, :bagpipe, :entroment]
    end

    def generate_user_groups
      if Ha2itat.quart.plugins.enabled?(:user)
        interactive_plugins.each do |loaded_plugin|
          cname = loaded_plugin.name.to_s.capitalize
          r = Class.new(::Plugins::User::Groups::UserGroup)
          ::Plugins::User::Groups.const_set(cname, r)
        end
      end

    end

    # every loaded plugin might provide a `plugin.js' in its root
    # collect possible existing files in a list and write an include file to
    # apps assets
    def self.write_javascript_include_file!(which = "be")
      toinclude =  Ha2itat.adapter.keys.map(&:to_s)
      included = []

      Ha2itat.log("[#{which}] writing plugin javascript imports #{ PP.pp(toinclude, "").strip.gsub("\n", "") }")

      incs = toinclude.map{ |tinc|
        file = "vendor/gems/ha2itat/plugins/#{tinc}/plugin-#{which}.js"

        unless ::File.exist?( Ha2itat.quart.path(file) )
          next
        end
        included << file
        "import '/./#{file}';"
      }.compact

      slice_include_file = Ha2itat.quart.
                             path("app/assets/javascript/slice_includes.generated-#{which}.js")

      incs.unshift "// File is overwritten everytime the app starts\n"
      ::File.open(slice_include_file, "w+") { |fp|
        fp.puts(incs.join("\n"))
      }
      for_log = included.map{|f| ::File.basename(::File.dirname(f)) }
      Ha2itat.log(" + wrote #{PP.pp(for_log, "").strip.gsub("\n", "")} to #{slice_include_file} (#{::File.size(slice_include_file)}kb)")

      write_javascript_include_file!("fe") if which == "be"

      toinclude
    # rescue
    #   puts :nope
    end

  end

  class Plugin
    attr_accessor :path
    attr_reader   :name, :loaded

    include LogInBlock

    def initialize(name)
      @name = name.to_sym
    end

    def plugin_root(*args)
      File.expand_path(Ha2itat.plugin_root(@name.to_s, *args))
    end

    def =~(othersym)
      @name == othersym
    end

    def try_adapter_file
      file = plugin_root("adapter.rb")

      if ::File.exist?(file)
        do_log("loading adapter file #{file}") do
          require file
        end
      else
        false
      end
    end

    def try_load
      loaded_files = ["%s.rb", "lib/%s.rb"].map do |s|
        if ::File.exist?(file=plugin_root(s % name.to_s))
          do_log("require plugin #{file}") do
            require file
          end
        else
          nil
        end
      end.compact
      loaded_files
    end

    def slice
      @slice ||= Ha2itat::Slices.const_get(name.to_s.capitalize).const_get(:Slice)
    rescue
      nil
    end

    def try_load_slice
      slice_source_file = plugin_root("slice", "slice.rb")
      do_log("loading slice #{slice_source_file}") do
        if ::File.exist?(slice_source_file)
          require slice_source_file
          true
        else
          false
        end
      end
      return false
    end

    def register_slice(app)
      app.register_slice(name, slice)
    end

  end

end
