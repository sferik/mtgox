require 'mtgox/offer'
require 'bigdecimal'

module MtGox
  class Order < Offer
    attr_accessor :id, :date, :item, :status, :currency

    def initialize(order = {})
      self.id     = order['oid']
      self.date   = Time.at(order['date'].to_i)
      self.amount = BigDecimal(order['amount']['value'])
      self.price  = BigDecimal(order['price']['value'])
      self.item   = order['item']
      self.status = order['status']
      self.currency = order['currency']
    end
  end
end
