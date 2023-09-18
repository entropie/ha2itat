require "pathname"

module Ha2itat

  Source = File.expand_path(File.join(File.dirname( File.expand_path(__FILE__))))


  def Source.join(*fragments)
    File.join(Source, *fragments)
  end
  
  def self.root(*argv)
    ::File.expand_path(Pathname.new(Source).join("..", *argv))
  end

  def self.plugin_root(*argv)
    Source.join("../plugins", *argv)
  end

  def self.media_path(*argv)
    quart.media_path(*argv)
  end


  module Ha2itat::Slices; end

  require_relative "mixins/fileutils"

  require_relative "ha2itat/database"
  require_relative "ha2itat/quarters"
  require_relative "ha2itat/plugins"
  require_relative "ha2itat/adapter"
  require_relative "ha2itat/calculated_version_hash"

  require_relative "app/warden"
  require_relative "app/actions"
  require_relative "app/views"

  # fixme
  require_relative "app/content_security_policy_overwrite"

  def self.quart=(obj)
    @quart = obj
  end

  def self.quart
    @quart
  end

  def self.default_adapter=(obj)
    @database_default_adapter = obj
  end

  def self.default_adapter
    @database_default_adapter || :File
  end

  def self.adapter(arg = nil)
    @adapter ||= Adapter.new
    ret = @adapter[arg.to_sym] if arg
    return ret if ret
    @adapter
  end

  def self.add_adapter(name, clz)
    Ha2itat.log "adding adapter #{name}"
    adapter[name.to_sym] = clz.get_default_adapter_initialized
    clz
  end

  def self.quart_from_path(path)
    Quarters.from_path(path)
  end

  def self.log(*args)
    Hanami.app["logger"].info(*args)
  rescue
    args.each do |arg|
      $stdout.puts ">>> #{arg}"
    end
  end

  def log(*args)
    Ha2itat.log(*args)
  end

end

Ha2itat.quart = Ha2itat.quart_from_path(Dir.pwd)
