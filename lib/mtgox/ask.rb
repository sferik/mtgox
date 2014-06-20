require 'mtgox/offer'
require 'mtgox/value'

module MtGox
  class Ask < Offer
    include MtGox::Value

    def initialize(client, hash = nil)
      self.client = client
      return if hash.nil?
      self.price = value_currency hash, 'price_int'
      self.amount = value_bitcoin hash, 'amount_int'
      self.timestamp = hash['stamp']
    end

    def eprice
      price / (1 - client.commission)
    end
  end
end
