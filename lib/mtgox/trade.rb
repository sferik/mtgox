require 'mtgox/order'

module MtGox
  class Trade < Order
    def initialize(trade = {})
      self.id     = trade['tid'].to_i
      self.date   = Time.at(trade['date'].to_i)
      self.amount = BigDecimal(trade['amount'])
      self.price  = BigDecimal(trade['price'])
    end
  end
end
