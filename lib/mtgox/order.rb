require 'mtgox/offer'

module MtGox
  class Order < Offer
    attr_accessor :id, :date

    def initialize(order={})
      self.id     = order['oid']
      self.date   = Time.at(order['date'].to_i)
      self.amount = order['amount']['value'].to_f
      self.price  = order['price']['value'].to_f
    end
  end
end
