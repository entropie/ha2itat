
require "pp"

require "pathname"
require "hanami"

module Ha2itat

  Source = File.expand_path(File.join(File.dirname( File.expand_path(__FILE__))))

  def self.root(*argv)
    expanded_root = ::File.expand_path(::File.join(Source, ".."))
    Pathname.new(expanded_root).join(*argv)
  end

  def self.plugin_root(*argv)
    root.join("plugins", *argv)
  end

  def self.template_root(*argv)
    root.join(root, "templates", *argv)    
  end

  def self.media_path(*argv)
    quart.media_path(*argv)
  end

  module Helper
  end
  
  def self.S(path)
    File.join("./", path.to_s.sub(root.to_s, ""))
  end

  require_relative "mixins/fileutils"
  require_relative "mixins/log_in_block"
  require_relative "mixins/pretty_date"

  require_relative "app/component_backend_definitions"
  require_relative "app/routes_extension"

  require_relative "ha2itat/database"
  require_relative "ha2itat/quarters"
  require_relative "ha2itat/plugins"
  require_relative "ha2itat/adapter"
  require_relative "ha2itat/calculated_version_hash"
  require_relative "ha2itat/renderer"

  require_relative "app/i18n"
  require_relative "app/pager"
  require_relative "app/meta"
  require_relative "app/slices"
  require_relative "app/warden"
  require_relative "app/actions"
  require_relative "app/views"

  require "redcarpet"

  def self.quart=(obj)
    @quart = obj
  end

  def self.quart
    @quart
  end

  def app
    Hanami.app
  end
  module_function :app

  def C(whatsymb)
    tart = whatsymb.to_sym
    SETTING_HASH[tart]
  end
  module_function :C
  
  def self.h(helper)
    Ha2itat::Helper.const_get( app.inflector.camelize(helper) )
  end

  def self.default_adapter=(obj)
    @database_default_adapter = obj
  end

  def self.default_adapter
    @database_default_adapter || :File
  end

  def self.adapter(arg = nil)
    @adapter ||= Adapter.new(Ha2itat.quart)
    if arg
      ret = @adapter[arg.to_sym]
      raise "adapter #{arg} requested but not found" unless ret
      return ret
    end
    @adapter
  end

  def self.add_adapter(name, clz)
    adapter[name] = clz.get_default_adapter_initialized
  end

  def self.quart_from_path(path)
    Quarters.from_path(path)
  end

  def self.log(msg)
    if Hanami.app.keys.include?("logger")
      Hanami.app["logger"].info(msg)
    elsif Ha2itat.quart.development?
      raise Hanami::AppLoadError
    else
    end
  rescue Hanami::AppLoadError
    $stdout.puts "h2> #{msg}"
  end

  def self.debug(msg)
    if Hanami.app.keys.include?("logger")
      Hanami.app["logger"].debug(msg)
    elsif Ha2itat.quart.development?
      raise Hanami::AppLoadError
    else
    end
  rescue Hanami::AppLoadError
    $stdout.puts "h2| #{msg}"
  end

  def self.warn(msg)
    if Hanami.app.keys.include?("logger")
      Hanami.app["logger"].warn(msg)
    elsif Ha2itat.quart.development?
      raise Hanami::AppLoadError
    else
    end
  rescue Hanami::AppLoadError
    $stdout.puts "h2! #{msg}"
  end




  def log(*args)
    Ha2itat.log(*args)
  end

end

Ha2itat.quart = Ha2itat.quart_from_path(Dir.pwd)
