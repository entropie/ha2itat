module Ha2itat

  module LogInBlock
    def do_log(msg, prfx = "[%s]")
      raise ":do_log called w/o block" unless block_given?
      ret = !!yield
      msg = "#{prfx}#{msg}"
      Ha2itat.log(msg % (ret and "+" or "-"))
    end
    module_function :do_log
  end

end
