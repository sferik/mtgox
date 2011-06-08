require 'mtgox/connection'
require 'mtgox/request'

module MtGox
  class Client
    include MtGox::Connection
    include MtGox::Request

    # Fetch the latest ticker data
    #
    # @return [Hashie::Rash]
    # @example
    #   MtGox.ticker
    def ticker
      get('/code/data/ticker.php')['ticker']
    end

    # Fetch open asks
    #
    # @return [Array<Numeric>]
    # @example
    #   MtGox.asks
    def asks
      get('/code/data/getDepth.php')['asks']
    end

    # Fetch open bids
    #
    # @return [Array<Numeric>]
    # @example
    #   MtGox.bids
    def bids
      get('/code/data/getDepth.php')['bids']
    end

    # Fetch recent trades
    #
    # @return [Array<Hashie::Rash>]
    # @example
    #   MtGox.trades
    def trades
      get('/code/data/getTrades.php').each{|t| t['date'] = Time.at(t['date'])}
    end
  end
end
