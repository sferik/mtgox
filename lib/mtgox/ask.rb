require 'mtgox/offer'

module MtGox
  class Ask < Offer

    def eprice
      price / (1 - commission)
    end

  end
end
