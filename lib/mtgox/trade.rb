require 'mtgox/order'

module MtGox
  class Trade < Order

    def initialize(trade={})
      self.id     = trade['tid'].to_i
      self.date   = Time.at(trade['date'].to_i)
      self.amount = trade['amount'].to_f
      self.price  = trade['price'].to_f
    end
  end
end
