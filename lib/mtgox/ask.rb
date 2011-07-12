require 'mtgox/offer'

module MtGox
  class Ask < Offer

    def eprice
      price / (1 - MtGox.commission)
    end

  end
end
