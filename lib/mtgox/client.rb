require 'faraday/error'
require 'mtgox/ask'
require 'mtgox/balance'
require 'mtgox/bid'
require 'mtgox/buy'
require 'mtgox/connection'
require 'mtgox/max_bid'
require 'mtgox/min_ask'
require 'mtgox/request'
require 'mtgox/sell'
require 'mtgox/ticker'
require 'mtgox/trade'

module MtGox
  class Client
    include MtGox::Connection
    include MtGox::Request

    ORDER_TYPES = {sell: "ask", buy: "bid"}
    INT_MULTIPLIERS = {btc: 100000000, usd: 100000, jpy: 1000}

    # Fetch a deposit address
    # @authenticated true
    # @return [String]
    # @example
    #   MtGox.address
    def address
      post('/api/0/btcAddress.php')['addr']
    end


    # Fetch the latest ticker data
    #
    # @authenticated false
    # @return [MtGox::Ticker]
    # @example
    #   MtGox.ticker
    def ticker
      ticker = get('/api/0/data/ticker.php')['ticker']
      Ticker.instance.buy    = ticker['buy'].to_f
      Ticker.instance.high   = ticker['high'].to_f
      Ticker.instance.price  = ticker['last'].to_f
      Ticker.instance.low    = ticker['low'].to_f
      Ticker.instance.sell   = ticker['sell'].to_f
      Ticker.instance.volume = ticker['vol'].to_f
      Ticker.instance.vwap   = ticker['vwap'].to_f
      Ticker.instance
    end

    # Fetch both bids and asks in one call, for network efficiency
    #
    # @authenticated false
    # @return [Hash] with keys :asks and :asks, which contain arrays as described in {MtGox::Client#asks} and {MtGox::Clients#bids}
    # @example
    #   MtGox.offers
    def offers
      offers = get('/api/0/data/getDepth.php')
      asks = offers['asks'].sort_by do |ask|
        ask[0].to_f
      end.map! do |ask|
        Ask.new(*ask)
      end
      bids = offers['bids'].sort_by do |bid|
        -bid[0].to_f
      end.map! do |bid|
        Bid.new(*bid)
      end
      {asks: asks, bids: bids}
    end

    # Fetch open asks
    #
    # @authenticated false
    # @return [Array<MtGox::Ask>] an array of open asks, sorted in price ascending order
    # @example
    #   MtGox.asks
    def asks
      offers[:asks]
    end

    # Fetch open bids
    #
    # @authenticated false
    # @return [Array<MtGox::Bid>] an array of open bids, sorted in price descending order
    # @example
    #   MtGox.bids
    def bids
      offers[:bids]
    end

    # Fetch the lowest priced ask
    #
    # @authenticated false
    # @return [MtGox::MinAsk]
    # @example
    #   MtGox.min_ask
    def min_ask
      min_ask = asks.first
      MinAsk.instance.price = min_ask.price
      MinAsk.instance.amount = min_ask.amount
      MinAsk.instance
    end

    # Fetch the highest priced bid
    #
    # @authenticated false
    # @return [MtGox::MinBid]
    # @example
    #   MtGox.max_bid
    def max_bid
      max_bid = bids.first
      MaxBid.instance.price = max_bid.price
      MaxBid.instance.amount = max_bid.amount
      MaxBid.instance
    end

    # Fetch recent trades
    #
    # @authenticated false
    # @return [Array<MtGox::Trade>] an array of trades, sorted in chronological order
    # @example
    #   MtGox.trades
    def trades
      get('/api/0/data/getTrades.php').sort_by{|trade| trade['date']}.map do |trade|
        Trade.new(trade)
      end
    end

    # Fetch your current balance
    #
    # @authenticated true
    # @return [Array<MtGox::Balance>]
    # @example
    #   MtGox.balance
    def balance
      parse_balance(post('/api/1/generic/private/info', {})['return'])
    end

    # Fetch your open orders, both buys and sells, for network efficiency
    #
    # @authenticated true
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   MtGox.orders
    def orders
      parse_orders(post('/api/1/generic/private/orders', {})['return'])
    end

    # Fetch your open buys
    #
    # @authenticated true
    # @return [Array<MtGox::Buy>] an array of your open bids, sorted by date
    # @example
    #   MtGox.buys
    def buys
      orders[:buys]
    end

    # Fetch your open sells
    #
    # @authenticated true
    # @return [Array<MtGox::Sell>] an array of your open asks, sorted by date
    # @example
    #   MtGox.sells
    def sells
      orders[:sells]
    end

    # Place a limit order to buy BTC
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to purchase
    # @param price [Numeric] the bid price in US dollars
    # @return [String] order ID for the buy, can be inspected using order_result
    # @example
    #   # Buy one bitcoin for $0.011
    #   MtGox.buy! 1.0, 0.011
    def buy!(amount, price)
      addorder!(:buy, amount, price)
    end

    # Place a limit order to sell BTC
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to sell
    # @param price [Numeric] the ask price in US dollars
    # @return [String] order ID for the sell, can be inspected using order_result
    # @example
    #   # Sell one bitcoin for $100
    #   MtGox.sell! 1.0, 100.0
    def sell!(amount, price)
      addorder!(:sell, amount, price)
    end

    # Create a new order
    #
    # @authenticated true
    # @param type [String] the type of order to create, either "buy" or "sell"
    # @param amount [Numberic] the number of bitcoins to buy/sell
    # @param price [Numeric] the bid/ask price in USD
    # @return [String] order ID for the order, can be inspected using order_result
    # @example
    #   # Sell one bitcoin for $123
    #   MtGox.addorder! :sell, 1.0, 123.0
    def addorder!(type, amount, price)
      post('/api/1/BTCUSD/private/order/add', {type: order_type(type), amount_int: intify(amount,:btc), price_int: intify(price, :usd)})['return']
    end

    # Cancel an open order
    #
    # @authenticated true
    # @overload cancel(oid)
    #   @param oid [String] an order ID
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order.oid
    #     MtGox.cancel 1234567890
    # @overload cancel(order)
    #   @param order [Hash] a hash-like object, with keys `oid` - the order ID of the transaction to cancel and `type` - the type of order to cancel (`1` for sell or `2` for buy)
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order
    #     MtGox.cancel {'oid' => '1234567890', 'type' => 2}
    def cancel(args)
      if args.is_a?(Hash)
        order = args.delete_if{|k, v| !['oid', 'type'].include?(k.to_s)}
        parse_orders(post('/api/0/cancelOrder.php', order)['orders'])
      else
        orders = post('/api/0/getOrders.php', {})['orders']
        order = orders.find{|order| order['oid'] == args.to_s}
        if order
          order = order.delete_if{|k, v| !['oid', 'type'].include?(k.to_s)}
          parse_orders(post('/api/0/cancelOrder.php', order)['orders'])
        else
          raise Faraday::Error::ResourceNotFound, {status: 404, headers: {}, body: 'Order not found.'}
        end
      end
    end

    # Transfer bitcoins from your Mt. Gox account into another account
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to withdraw
    # @param btca [String] the bitcoin address to send to
    # @return [String] completed transaction ID
    # @example
    #   # Withdraw 1 BTC from your account
    #   MtGox.withdraw! 1.0, '1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L'
    def withdraw!(amount, address)
      post('/api/1/generic/bitcoin/send_simple', {amount_int: intify(amount, :btc), address: address})['return']['trx']
    end

    private

    def parse_balance(balance)
      balances = []
      balances << Balance.new('BTC', balance['Wallets']['BTC']['Balance']['value'])
      balances << Balance.new('USD', balance['Wallets']['USD']['Balance']['value'])
      balances
    end

    def parse_orders(orders)
      buys = []
      sells = []
      orders.sort_by{|order| order['date']}.each do |order|
        case order['type']
        when ORDER_TYPES[:sell]
          sells << Sell.new(order)
        when ORDER_TYPES[:buy]
          buys << Buy.new(order)
        end
      end
      {buys: buys, sells: sells}
    end

    def intify(float, currency)
     (float * INT_MULTIPLIERS[currency]).to_i
    end

    def order_type(type)
      unless ["bid", "ask"].include?(type.to_s)
        ORDER_TYPES[type.downcase.to_sym]
      else
        type
      end
    end
  end
end
