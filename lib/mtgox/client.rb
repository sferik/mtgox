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

    # places a buy request
    # requires name and pass to be set
    # TODO: usefully return something
    #
    # Array<Hashie::Rash>
    # @example
    #   MtGox.buy 1.0, 25.0 #buy one BTC for 25 usd
    def buy(quantity,price)
      post('/code/buyBTC.php',pass_params.merge({:amount=>quantity,:price=>price}))
      #.orders.select {|o| o.type == ORDER_TYPES[:sell]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end

    # places a sell request
    # requires name and pass to be set
    # TODO: usefully return something
    #
    # Array<Hashie::Rash>
    # @example
    #   MtGox.sell 0.7, 26.0 #sell 0.7 BTC for 26 usd
    def sell(quantity,price)
      post('/code/sellBTC.php',pass_params.merge({:amount=>quantity,:price=>price}))
      #.orders.select {|o| o.type == ORDER_TYPES[:sell]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end
    
    # cancels an open order
    # requires name and pass to be set
    # accepts as parameters as a hash-like object with "type" and "oid"
    # TODO: usefully return something
    #
    # Array<Hashie::Rash>
    # @example
    #   MtGox.cancel my_order
    #   MtGox.cancel {"oid" => "123", "type" => 2}
    def cancel(param)
      order_params = param.select {|k,v| ["oid", "type"].include? k.to_s}
      post('/code/cancelOrder.php',pass_params.merge(order_params))
      #.orders.select {|o| o.type == ORDER_TYPES[:sell]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end

    
    
    
    private
    def pass_params
      {"name"=>MtGox.name,"pass"=>MtGox.pass}
    end
    
  end
end
