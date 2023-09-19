module Ha2itat
  class Quarters < Array

    def self.from_path(path)
      Quart.new(path)
    end

  end

  class Quart
    attr_reader :ident
    attr_accessor :secret

    def initialize(path)
      @path = path
      @ident = ::File.basename(path).to_sym
    end

    def inspect
      "<#{ident}: #{plugins.inspect}>"
    end

    def plugins(&blk)
      @plugins ||= ::Ha2itat::Plugins.new(self)
      if block_given?
        @plugins.transaction(&blk)
      end
      @plugins
    end

    def path(*args)
      ::File.join(@path, *args)
    end

    def media_path(*args)
      ::File.join(@path, "media", *args)
    end

    def env?(wenv)
      Hanami.env == wenv
    end

    def development?
      env?(:development)
    end

    def production?
      env?(:production)
    end

  end
end
