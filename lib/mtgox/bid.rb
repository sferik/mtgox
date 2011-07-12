require 'mtgox/offer'

module MtGox
  class Bid < Offer

    def eprice
      price * (1 - commission)
    end

  end
end
