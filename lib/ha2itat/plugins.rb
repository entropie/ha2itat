module Ha2itat

  class Plugins < Array
    def initialize(quart)
      @quart = quart
    end

    def register(arg)
      plugin_dir = Ha2itat.plugin_root(arg.to_s)
      raise "not existing path `#{plugin_dir}'" unless ::File.directory?(plugin_dir)
      new_plugin = Plugin.new(arg.to_sym)
      new_plugin.path = plugin_dir

      new_plugin.try_load
      new_plugin.try_provider_file
      new_plugin.try_load_slice and new_plugin.register_slice(Hanami.app)
      self << new_plugin
      self
    end

    def inspect
      "P(%s)" % map{ |plug| plug.name }.join(",")
    end

    def transaction(&blk)
      yield self
    end

    def write_javascript_include_file!
      Plugins.write_javascript_include_file!
    end

    # every loaded plugin might provide a `plugin.js' in its root
    def self.write_javascript_include_file!
      toinclude = []
      Ha2itat.adapter.each_pair do |adapter_ident, adapter|
        toinclude << adapter_ident
      end

      Ha2itat.log("writing plugin javascript imports #{ PP.pp(toinclude, "").strip }")
      incs = toinclude.map(&:to_s).map{ |tinc|
        file = "vendor/gems/ha2itat/plugins/#{tinc}/plugin.js"
        next unless::File.exist?( Ha2itat.quart.path(file) )
        relative_file = "/./#{file}"
        "import '#{relative_file}';"
      }.compact
    
      slice_include_file = Ha2itat.quart.
                             path("app/assets/javascript/slice_includes.generated.js")
      ::File.open(slice_include_file, "w+") { |fp| fp.puts(incs.join("\n")) }
      Ha2itat.log(" + wrote #{slice_include_file} (#{::File.size(slice_include_file)}kb)")
      toinclude
    end

  end

  class Plugin
    attr_accessor :path
    attr_reader   :name, :loaded

    def initialize(name)
      @name = name.to_sym
    end

    def plugin_root(*args)
      Ha2itat.plugin_root(@name.to_s, *args)
    end

    def =~(othersym)
      @name == othersym
    end

    def try_provider_file
      file = Ha2itat.plugin_root(name.to_s, "provider.rb")

       if ::File.exist?(file)
         Ha2itat.log " + try_provider_file #{file}"
         require file
       else
         Ha2itat.log " X try_provider_file #{file} (not-existing)"
         false
       end
    end
    
    def try_load
      Ha2itat.log " #{name} plugin try_load..."
      loaded = 0
      loaded_files = ["%s.rb", "lib/%s.rb"].map do |s|
        if ::File.exist?(file=plugin_root(s % name.to_s))
          loaded =+ 1
          Ha2itat.log " + require #{file}"
          require file
          file
        else
          nil
        end
      end.compact
      Ha2itat.log " + required #{loaded} file(s)"
    end

    def slice
      @slice ||= Ha2itat::Slices.const_get(name.to_s.capitalize).const_get(:Slice)
    rescue
      nil
    end

    def try_load_slice
      Ha2itat.log " + trying slice..."
      string_name = name.to_s
      slice_source_file = plugin_root("slice", "#{string_name}.rb")
      if ::File.exist?(slice_source_file)
        require slice_source_file
        Ha2itat.log " + success: #{slice}"
        return true
      end
      Ha2itat.log " ! failed"
      return false
    end

    def register_slice(app)
      app.register_slice(name, slice)
    end

  end

end
