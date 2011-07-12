require 'mtgox/ask'
require 'singleton'

module MtGox
  class MinAsk < Ask
    include Singleton
    attr_accessor :previous_price

    def price=(price)
      @previous_price = @price
      @price = price
    end

    def up?
      price > previous_price.to_f
    end

    def down?
      price < previous_price.to_f
    end

    def changed?
      price != previous_price.to_f
    end

    def unchanged?
      !changed?
    end
    alias :unch? :unchanged?

  end
end
