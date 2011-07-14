require 'mtgox/ask'
require 'mtgox/price_ticker'
require 'singleton'

module MtGox
  class MinAsk < Ask
    include Singleton
    include PriceTicker
  end
end
