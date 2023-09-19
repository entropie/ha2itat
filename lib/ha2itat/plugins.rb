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
      self << new_plugin
      self
    end

    def inspect
      "P(%s)" % map{ |plug| plug.name }.join(",")
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
         load file
       else
         Ha2itat.log " X try_provider_file #{file} (not-existing)"
         false
       end
    end
    
    def try_load
      Ha2itat.log "plugin try_load(#{name})"
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

  end

end
