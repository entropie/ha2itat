require "fileutils"

module Ha2itat::Mixins
  module FU
    extend FileUtils
    include FileUtils

    VERBOSE = false

    def __verbose
      @__verbose || VERBOSE
    end

    def do_quite
      old_verb = __verbose
      @__verbose = false
      self
      @__verbose = old_verb
    end

    def mkdir_p(f, *args)
      Ha2itat.log("mkdir: #{f}")
      FileUtils.mkdir_p(f, :verbose => __verbose)
    end

    def cp(s, t)
      Ha2itat.log("cp: #{s} => #{t}")
      FileUtils.cp_r(s, t, :verbose => __verbose)
    end

    def rm_rf(fod)
      Ha2itat.log( "rm -rf: #{fod}")
      FileUtils.rm_rf(fod)
    end

    def dirname(s)
      File.dirname(s)
    end

    def cleaned_content(str)
      str.gsub(/\r/, "")
    end
    module_function :cleaned_content
    
    def overwrite(file, cnts)
      cnts = cleaned_content(cnts)
      r=File.open(file, "w+") do |fp|
        fp.puts(cnts)
      end
      Ha2itat.log "overwritten: #{file} #{r}"
    end

    def write(file, cnts)
      cnts = cleaned_content(cnts)

      FileUtils.mkdir_p(::File.dirname(file), :verbose => __verbose)

      r=File.open(file, "w+") do |fp|
        fp.puts(cnts)
      end
      Ha2itat.log "write: #{file} #{r}"
    end

    module_function :write

    def log(*args)
      args.each{|a| Ha2itat.log(a) }
    end
    
    
  end
end
