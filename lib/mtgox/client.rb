require 'mtgox/connection'
require 'mtgox/request'

module MtGox
  class Client
    include MtGox::Connection
    include MtGox::Request

    # Fetch the latest ticker data
    #
    # @return [Hashie::Rash] with keys :buy - current highest bid price, :sell - current lowest ask price, :high - highest price trade for the day, :low - lowest price trade for the day, :last - price of most recent trade, :vol - unknown
    # @example
    #   MtGox.ticker #=> <#Hashie::Rash buy=19.29 high=19.96 last=19.36 low=19.01 sell=19.375 vol=29470>
    def ticker
      get('/code/data/ticker.php')['ticker']
    end

    # Fetch open asks
    #
    # @return [Array<Array<Numeric>>] returns an array of arrays of numbers. these are of the form [price,quantity]. The array is sorted in price ascending order
    # @example
    #   MtGox.asks[0,3] #=> [[19.3898, 3.9], [19.4, 48.264], [19.409, 1]]
    def asks
      get('/code/data/getDepth.php')['asks']
    end

    # Fetch open bids
    #
    # @return [Array<Array<Numeric>>] returns an array of arrays of numbers. these are of the form [price,quantity]. the array is sorted in price descending order
    # @example
    #   MtGox.bids[0,3] #=> [[19.3898, 77.42], [19.3, 3.02], [19.29, 82.378]]
    def bids
      get('/code/data/getDepth.php')['bids']
    end

    # Fetch both bids & asks in one call, for network efficiency
    #
    # @return [Hashie::Rash] a hash with keys "asks" and "buys", which contain arrays as described in #asks and #bids
    # @example
    #   o=MtGox.offers;
    #   o.asks[0,3] #=> [[19.3898, 3.9], [19.4, 48.264], [19.409, 1]]
    #   o.bids[0,3] #=> [[19.3898, 77.42], [19.3, 3.02], [19.29, 82.378]]
    def offers
      get('/code/data/getDepth.php')
    end


    # Fetch recent trades
    #
    # @return [Array<Hashie::Rash>] an array of trades, sorted in chronological order. each trade is a Hashie::Rash, with keys :amount - number of bitcoins traded, :price - price they were traded at, in USD, :date - time and date of the trade (ruby Time object), :tid - Trade ID
    # @example
    #   MtGox.trades[0,3] #=> [<#Hashie::Rash amount=41 date=2011-06-14 11:26:32 -0700 price=18.5 tid="183747">, <#Hashie::Rash amount=5 date=2011-06-14 11:26:44 -0700 price=18.5 tid="183748">, <#Hashie::Rash amount=5 date=2011-06-14 11:27:00 -0700 price=18.42 tid="183749">]
    def trades
      get('/code/data/getTrades.php').each{|t| t['date'] = Time.at(t['date'])}
    end
    
    # Fetch your balance
    # requires name and pass to be set
    #
    # @return [Hashie::Rash] with keys :btcs - amount of bitcoins in your account, :usds - amount of USD in your account
    # @example
    #   MtGox.balance #=> <#Hashie::Rash btcs=3.7 usds=12> #this person has 3.7 bitcoins, and 12 dollars
    def balance
      post('/code/getFunds.php',pass_params)
    end

    # Fetch your open bitcoin purchases
    # requires name and pass to be set
    #
    # @return [Array<Hashie::Rash>] an array of your open bids, sorted by price ascending each bid is a Hashie::Rash, with keys :amount, :dark, :date, :oid, :price, :status, and :type
    # @example
    #   MtGox.buys[0,3] #=> [<#Hashie::Rash amount=0.73 dark="0" date="1307949196" oid="929284" price=2 status=:active type=2>, <#Hashie::Rash amount=0.36 dark="0" date="1307949201" oid="929288" price=4 status=:active type=2>, <#Hashie::Rash amount=0.24 dark="0" date="1307949212" oid="929292" price=6 status=:active type=2>]
    def buys
      post('/code/getOrders.php',pass_params).orders.select {|o| o.type == ORDER_TYPES[:buy]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end

    # Fetch your open bitcoin sells
    # requires name and pass to be set
    #
    # @return [Array<Hashie::Rash>] an array of your open asks, sorted by price ascending each bid is a Hashie::Rash, with keys :amount, :dark, :date, :oid, :price, :status, and :type
    # @example
    #   MtGox.sells[0,3] #=> [<#Hashie::Rash amount=0.1 dark="0" date="1307949384" oid="663465" price=24.92 status=nil type=1>, <#Hashie::Rash amount=0.12 dark="0" date="1307949391" oid="663468" price=25.65 status=nil type=1>, <#Hashie::Rash amount=0.15 dark="0" date="1307949396" oid="663470" price=26.38 status=nil type=1>]
    def sells
      post('/code/getOrders.php',pass_params).orders.select {|o| o.type == ORDER_TYPES[:sell]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end

    # Fetch your open orders, both buys and sells, for network efficiency.
    # requires name and pass to be set
    #
    # @return [<Hashie::Rash>] a Hashie::Rash with keys :buy and :sell, which contain arrays as described in #buys and #sells
    # @example
    #   o=MtGox.orders
    #   o.buy[0,3]  #=> [<#Hashie::Rash amount=0.73 dark="0" date="1307949196" oid="929284" price=2 status=:active type=2>, <#Hashie::Rash amount=0.36 dark="0" date="1307949201" oid="929288" price=4 status=:active type=2>, <#Hashie::Rash amount=0.24 dark="0" date="1307949212" oid="929292" price=6 status=:active type=2>]
    #   o.sell[0,3] #=> [<#Hashie::Rash amount=0.1 dark="0" date="1307949384" oid="663465" price=24.92 status=nil type=1>, <#Hashie::Rash amount=0.12 dark="0" date="1307949391" oid="663468" price=25.65 status=nil type=1>, <#Hashie::Rash amount=0.15 dark="0" date="1307949396" oid="663470" price=26.38 status=nil type=1>]
    def orders
      hash = post('/code/getOrders.php',pass_params).orders.each {|o| o.status = STATUS_TYPES[o.status]; o.type=ORDER_TYPES.invert[o.type]}.group_by(&:type)
      Hashie::Rash.new(hash)
    end


    # places a buy request
    # requires name and pass to be set
    # TODO: usefully return something
    #
    # @param [Numeric] quantity the number of bitcoins to purchase
    # @param [Numeric] price the price to buy them at 
    # @return [Array<Hashie::Rash>]
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
    # @param [Numeric] quantity the number of bitcoins to sell
    # @param [Numeric] price the price to sell them at 
    # @return [Array<Hashie::Rash>]
    # @example
    #   MtGox.sell 0.7, 26.0 #sell 0.7 BTC for 26 usd
    def sell(quantity,price)
      post('/code/sellBTC.php',pass_params.merge({:amount=>quantity,:price=>price}))
      #.orders.select {|o| o.type == ORDER_TYPES[:sell]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end
    
    # cancels an open order
    # requires name and pass to be set
    # accepts as parameters as a hash-like object with "type" and "oid"
    # type can either be a number (1,2) or a symbol (:buy,:sell)
    # TODO: usefully return something
    #
    # @param [Hash] a hash-like object, with keys "oid": order ID of the transaction to cancel, and "type": the type of order to cancel. this can be a literal '1','2', or a symbolic :buy, :sell
    # @return Array<Hashie::Rash>
    # @example
    #   MtGox.cancel my_order
    #   MtGox.cancel {"oid" => "123", "type" => 2}
    def cancel(param)
      order_params = param.select {|k,v| ["oid", "type"].include? k.to_s}
      order_params["type"] = ORDER_TYPES[order_params["type"]]  || order_params["type"]
      post('/code/cancelOrder.php',pass_params.merge(order_params))
      #.orders.select {|o| o.type == ORDER_TYPES[:sell]}.each {|o| o.status = STATUS_TYPES[o.status]}
    end

    
    private
    def pass_params
      {"name"=>MtGox.name,"pass"=>MtGox.pass}
    end
    
  end
end
