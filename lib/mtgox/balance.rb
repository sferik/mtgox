module MtGox
  class Balance
    attr_accessor :currency, :amount

    def initialize(currency=nil, amount=nil)
      self.currency = currency.to_s.upcase
      self.amount = BigDecimal(amount.to_s)
    end
  end
end
