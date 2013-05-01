require 'mtgox/ask'
require 'mtgox/price_ticker'

module MtGox
  class MinAsk < Ask
    include PriceTicker
  end
end
