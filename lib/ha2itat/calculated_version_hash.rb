module Ha2itat

  def self.commit_hash
    @commit_hash ||= `cd #{Source} && git rev-parse HEAD`.strip.freeze
  end

  def self.quart_commit_hash
    raise "quart not initialized but git hash requested" unless @quart
    @quart_commit_hash ||= `cd #{quart.path} && git rev-parse HEAD`.strip.freeze
  end

  def self.calculated_version_hash
    unless @calculated_version_hash
      @calculated_version_hash = Digest::SHA2.new(256).hexdigest(commit_hash + quart_commit_hash)[0..12]
      if quart.development?
        @calculated_version_hash += "&r=#{rand(999)}"
      end
    end
    @calculated_version_hash
  end

  def self.calculate_version_hash!
    unless @calculate_version_hash
      log :info, "reading git revs from both repositories"
    end
    calculated_version_hash
  end

end
