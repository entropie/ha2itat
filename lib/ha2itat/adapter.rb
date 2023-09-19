module Ha2itat
  class Adapter < Hash
    attr_reader :quart
    def initialize(quart)
      @quart = quart
    end

    def each_pair(&blk)
      sort_by{ |k,v| (v.respond_to?(:order) and v.order) or 5 }.each { |h,k|
        yield h,k
      }

    end
  end
end
