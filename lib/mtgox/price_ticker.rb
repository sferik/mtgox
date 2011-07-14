module MtGox
  module PriceTicker
    attr_reader :previous_price, :price

    def price=(price)
      @previous_price = @price
      @price = price
    end

    def up?
      price.to_f > previous_price.to_f
    end

    def down?
      price.to_f < previous_price.to_f
    end

    def changed?
      price.to_f != previous_price.to_f
    end

    def unchanged?
      !changed?
    end
    alias :unch? :unchanged?
  end
end
