module MtGox
  module PriceTicker
    attr_reader :previous_price, :price

    def price=(price)
      @previous_price = @price
      @price = price
    end

    def up?
      BigDecimal(price) > BigDecimal(previous_price)
    end

    def down?
      BigDecimal(price) < BigDecimal(previous_price)
    end

    def changed?
      BigDecimal(price) != BigDecimal(previous_price)
    end

    def unchanged?
      !changed?
    end
    alias :unch? :unchanged?
  end
end
