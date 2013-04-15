require 'mtgox/offer'
require 'mtgox/value'

module MtGox
  class Ask < Offer
    include MtGox::Value

    def initialize(hash = nil)
      if hash
        self.price = value_currency hash, 'price_int'
        self.amount = value_bitcoin hash, 'amount_int'
        self.timestamp = hash['stamp']
      end
    end

    def eprice
      price / (1 - MtGox.commission)
    end

  end
end
