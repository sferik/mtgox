module MtGox
  module PriceTicker
    attr_reader :previous_price, :price

    def price=(price)
      @previous_price = @price
      @price = price
    end

    def up?
      BigDecimal(price.to_s) > BigDecimal(previous_price.to_s)
    end

    def down?
      BigDecimal(price.to_s) < BigDecimal(previous_price.to_s)
    end

    def changed?
      BigDecimal(price.to_s) != BigDecimal(previous_price.to_s)
    end

    def unchanged?
      !changed?
    end
    alias :unch? :unchanged?
  end
end
