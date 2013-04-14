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
require 'mtgox/value'

module MtGox
  class Client
    include MtGox::Connection
    include MtGox::Request
    include MtGox::Value

    ORDER_TYPES = {sell: "ask", buy: "bid"}
    INT_MULTIPLIERS = {btc: 100000000, usd: 100000, jpy: 1000}

    # Fetch a deposit address
    # @authenticated true
    # @return [String]
    # @example
    #   MtGox.address
    def address
      post('/api/1/generic/bitcoin/address')['addr']
    end


    # Fetch the latest ticker data
    #
    # @authenticated false
    # @return [MtGox::Ticker]
    # @example
    #   MtGox.ticker
    def ticker
      ticker = get('/api/1/BTCUSD/ticker')
      Ticker.instance.buy    = value_currency ticker['buy']
      Ticker.instance.high   = value_currency ticker['high']
      Ticker.instance.price  = value_currency ticker['last_all']
      Ticker.instance.low    = value_currency ticker['low']
      Ticker.instance.sell   = value_currency ticker['sell']
      Ticker.instance.volume = value_bitcoin ticker['vol']
      Ticker.instance.vwap   = value_currency ticker['vwap']
      Ticker.instance.avg   = value_currency ticker['avg']
      Ticker.instance
    end

    # Fetch both bids and asks in one call, for network efficiency
    #
    # @authenticated false
    # @return [Hash] with keys :asks and :asks, which contain arrays as described in {MtGox::Client#asks} and {MtGox::Clients#bids}
    # @example
    #   MtGox.offers
    def offers
      offers = get('/api/1/BTCUSD/depth/fetch')
      asks = offers['asks'].sort_by do |ask|
        ask['price_int'].to_i
      end.map! do |ask|
        Ask.new(ask)
      end
      bids = offers['bids'].sort_by do |bid|
        -bid['price_int'].to_i
      end.map! do |bid|
        Bid.new(bid)
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
      get('/api/1/BTCUSD/trades/fetch').sort_by{|trade| trade['date']}.map do |trade|
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
      parse_balance(post('/api/1/generic/info', {}))
    end

    # Fetch your open orders, both buys and sells, for network efficiency
    #
    # @authenticated true
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   MtGox.orders
    def orders
      parse_orders post('/api/1/generic/orders', {})
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
      post('/api/1/BTCUSD/order/add', {type: order_type(type), amount_int: intify(amount,:btc), price_int: intify(price, :usd)})
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
    #   @param order [Hash] a hash-like object, containing at least a key `oid` - the order ID of the transaction to cancel
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order
    #     MtGox.cancel {'oid' => '1234567890'}
    def cancel(args)
      if args.is_a?(Hash)
        args = args['oid']
      end

      orders = post('/api/1/generic/orders', {})
      order = orders.find{|order| order['oid'] == args.to_s}
      if order
        res = post('/api/1/BTCUSD/order/cancel', {oid: order['oid']})
        orders.delete_if { |o| o['oid'] == res['oid'] }
        parse_orders(orders)
      else
        raise Faraday::Error::ResourceNotFound, {status: 404, headers: {}, body: 'Order not found.'}
      end
    end

    # Transfer bitcoins from your Mt. Gox account into another account
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to withdraw
    # @param address [String] the bitcoin address to send to
    # @return [String] Completed Transaction ID
    # @example
    #   # Withdraw 1 BTC from your account
    #   MtGox.withdraw! 1.0, '1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L'
    def withdraw!(amount, address)
      if amount >= 1000
        raise FilthyRichError,
        "#withdraw! take bitcoin amount as parameter (you are trying to withdraw #{amount} BTC"
      else
        post('/api/1/generic/bitcoin/send_simple', {amount_int: intify(amount, :btc), address: address})['trx']
      end
    end

    private

    def parse_balance(info)
      balances = []
      info['Wallets'].each do |currency, wallet|
        value = currency == "BTC" ? value_bitcoin(wallet['Balance']) : value_currency(wallet['Balance'])
        balances << Balance.new(currency, value)
      end
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
