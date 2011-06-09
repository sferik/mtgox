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
    
    # Fetch your balance
    # requires name and pass to be set
    #
    # @return [Hashie::Rash]
    # @example
    #   MtGox.balance
    def balance
      post('/code/getFunds.php',pass_params)
    end

    # Fetch your open bitcoin purchases
    # requires name and pass to be set
    #
    # [Array<Hashie::Rash>]
    # @example
    #   MtGox.buys
    def buys
      post('/code/getOrders.php',pass_params).orders.select {|o| o.type == ORDER_TYPES[:buy]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end

    # Fetch your open bitcoin sells
    # requires name and pass to be set
    #
    # [Array<Hashie::Rash>]
    # @example
    #   MtGox.sells
    def sells
      post('/code/getOrders.php',pass_params).orders.select {|o| o.type == ORDER_TYPES[:sell]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end    
    
    private
    def pass_params
      {"name"=>MtGox.name,"pass"=>MtGox.pass}
    end
    
  end
end
