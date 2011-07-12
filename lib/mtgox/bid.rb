require 'mtgox/offer'

module MtGox
  class Bid < Offer

    def initialize(price=nil, amount=nil)
      self.price = price.to_f
      self.amount = amount.to_f
    end

    def eprice
      price * (1 - MtGox.commission)
    end

  end
end
