require 'mtgox/offer'
require 'mtgox/value'

module MtGox
  class Bid < Offer
    include MtGox::Value

    def initialize(client, hash = nil)
      self.client = client
      if hash
        self.price = value_currency hash, 'price_int'
        self.amount = value_bitcoin hash, 'amount_int'
        self.timestamp = hash['stamp']
      end
    end

    def eprice
      price * (1 - self.client.commission)
    end

  end
end
