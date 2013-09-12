require 'helper'

describe MtGox::Client do
  before do
    @client = MtGox::Client.new
    @client.configure do |config|
      config.key = "key"
      config.secret = "secret"
    end
  end

  describe '#address' do
    before do
      stub_post('/api/1/generic/bitcoin/address').
        to_return(body: fixture('address.json'))
    end

    it "fetchs a deposit address" do
      address = @client.address
      expect(a_post('/api/1/generic/bitcoin/address')).to have_been_made
      expect(address).to eq '17A1vbzQ39o8cGNnpqx8UvXNrhqwAEP8wY'
    end
  end

  describe '#idkey' do
    before do
      stub_post('/api/1/generic/idkey').
        to_return(body: fixture('idkey.json'))
    end

    it "fetches an idkey suitable to WS Api usage" do
      key = @client.idkey
      expect(a_post('/api/1/generic/idkey')).to have_been_made
      expect(key).to eq 'YCKvmyU4QsaHEqM/AvKlqAAAAABRbR5y0vCn1roteQx/Ux/lyLF27X8Em1e4AN/2etPECzIT6dU'
    end
  end

  describe '#ticker' do
    before do
      stub_get('/api/1/BTCUSD/ticker').
        to_return(body: fixture('ticker.json'))
    end

    it "fetches the ticker" do
      ticker = @client.ticker
      expect(a_get('/api/1/BTCUSD/ticker')).to have_been_made
      expect(ticker.buy).to eq BigDecimal('5.53587')
      expect(ticker.sell).to eq BigDecimal('5.56031')
      expect(ticker.high).to eq BigDecimal('5.70653')
      expect(ticker.low).to eq BigDecimal('5.4145')
      expect(ticker.price).to eq BigDecimal('5.5594')
      expect(ticker.volume).to eq BigDecimal('55829.58960346')
      expect(ticker.vwap).to eq BigDecimal('5.61048')
      expect(ticker.avg).to eq BigDecimal('5.56112')
    end

    it "fetches the ticker and keep previous price" do
      ticker = @client.ticker
      ticker = @client.ticker
      expect(a_get('/api/1/BTCUSD/ticker')).to have_been_made.twice
      expect(ticker.up?).to be_false
      expect(ticker.down?).to be_false
      expect(ticker.changed?).to be_false
      expect(ticker.unchanged?).to be_true
    end
  end

  describe '#lag' do
    before do
      stub_get('/api/1/generic/order/lag').
        to_return(status:200, body: fixture('lag.json'))
    end

    it "fetches the lag" do
      lag = @client.lag
      expect(a_get('/api/1/generic/order/lag')).to have_been_made
      expect(lag.microseconds).to eq 535998
      expect(lag.seconds).to eq BigDecimal('0.535998')
      expect(lag.text).to eq "0.535998 seconds"
      expect(lag.length).to eq 3
    end
  end

  describe 'depth methods' do
    before :each do
      stub_get('/api/1/BTCUSD/depth/fetch').
        to_return(body: fixture('depth.json'))
    end

    describe '#asks' do
      it "fetches open asks" do
        asks = @client.asks
        expect(a_get('/api/1/BTCUSD/depth/fetch')).to have_been_made
        expect(asks.first.price).to eq 114
        expect(asks.first.eprice).to eq BigDecimal('114.745848012')
        expect(asks.first.amount).to eq BigDecimal('0.43936758')
      end

      it "should be sorted in price-ascending order" do
        asks = @client.asks
        expect(asks.sort_by(&:price)).to eq asks
      end

    end

    describe "#bids" do
      it "fetches open bids" do
        bids = @client.bids
        expect(a_get('/api/1/BTCUSD/depth/fetch')).to have_been_made
        expect(bids.first.price).to eq BigDecimal('113.0')
        expect(bids.first.eprice).to eq BigDecimal('112.2655')
        expect(bids.first.amount).to eq BigDecimal('124.69802063')
      end

      it "should be sorted in price-descending order" do
        bids = @client.bids
        expect(bids.sort_by(&:price).reverse).to eq bids
      end
    end

    describe "#offers" do
      it "fetches both bids and asks, with only one call" do
        offers = @client.offers
        expect(a_get('/api/1/BTCUSD/depth/fetch')).to have_been_made.once
        expect(offers[:asks].first.price).to eq 114
        expect(offers[:asks].first.eprice).to eq BigDecimal('114.745848012')
        expect(offers[:asks].first.amount).to eq BigDecimal('0.43936758')
        expect(offers[:bids].first.price).to eq BigDecimal('113.0')
        expect(offers[:bids].first.eprice).to eq BigDecimal('112.2655')
        expect(offers[:bids].first.amount).to eq BigDecimal('124.69802063')
      end
    end

    describe '#min_ask' do
      it "fetches the lowest priced ask" do
        min_ask = @client.min_ask
        expect(a_get('/api/1/BTCUSD/depth/fetch')).to have_been_made.once
        expect(min_ask.price).to eq 114
        expect(min_ask.eprice).to eq BigDecimal('114.745848012')
        expect(min_ask.amount).to eq BigDecimal('0.43936758')
      end
    end

    describe '#max_bid' do
      it "fetches the highest priced bid" do
        max_bid = @client.max_bid
        expect(a_get('/api/1/BTCUSD/depth/fetch')).to have_been_made.once
        expect(max_bid.price).to eq 113
        expect(max_bid.eprice).to eq BigDecimal('112.2655')
        expect(max_bid.amount).to eq BigDecimal('124.69802063')
      end
    end

  end

  describe '#trades' do
    before do
      stub_get('/api/1/BTCUSD/trades/fetch').
        to_return(body: fixture('trades.json'))
    end

    it "fetches trades" do
      trades = @client.trades
      expect(a_get('/api/1/BTCUSD/trades/fetch')).to have_been_made
      expect(trades.last.date).to eq Time.utc(2013, 4, 12, 15, 20, 3)
      expect(trades.last.price).to eq BigDecimal('73.19258')
      expect(trades.last.amount).to eq BigDecimal('0.94043572')
      expect(trades.last.id).to eq 1365780003374123
    end
  end

  describe '#trades :since' do
    before do
      trades = JSON.load(fixture('trades.json'))
      stub_get('/api/1/BTCUSD/trades/fetch?since=1365780002144150').
        to_return(body: JSON.dump({result: 'success', return: trades['return'].select{|t| t['tid'] >= '1365780002144150'}}))
    end

    it "fetches trades since an id" do
      trades = @client.trades :since => 1365780002144150
      expect(a_get('/api/1/BTCUSD/trades/fetch?since=1365780002144150')).to have_been_made
      expect(trades.first.price).to eq BigDecimal('72.98274')
      expect(trades.first.amount).to eq BigDecimal('11.76583944')
      expect(trades.first.id).to eq 1365780002144150
    end
  end

  describe "#rights" do
    before do
      stub_post('/api/1/generic/info').
        with(body: test_body, headers: test_headers(@client)).
        to_return(body: fixture('info.json'))
    end

    it "fetches the array of API permissions" do
      rights = @client.rights
      expect(a_post("/api/1/generic/info").with(body: test_body, headers: test_headers(@client))).to have_been_made
      expect(rights).to eq ["deposit", "get_info", "trade", "withdraw"]
    end
  end

  describe '#balance' do
    before do
      stub_post('/api/1/generic/info').
        with(body: test_body, headers: test_headers(@client)).
        to_return(body: fixture('info.json'))
    end

    it "fetches balance" do
      balance = @client.balance
      expect(a_post("/api/1/generic/info").with(body: test_body, headers: test_headers(@client))).to have_been_made
      expect(balance.first.currency).to eq "BTC"
      expect(balance.first.amount).to eq BigDecimal('42.0')
      expect(balance.last.currency).to eq "EUR"
      expect(balance.last.amount).to eq BigDecimal('23.0')
    end
  end

  describe "order methods" do
    before :each do
      stub_post('/api/1/generic/orders').
        with(body: test_body, headers: test_headers(@client)).
        to_return(body: fixture('orders.json'))
    end

    describe "#buys" do
      it "fetches orders" do
        buys = @client.buys
        expect(a_post("/api/1/generic/orders").with(body: test_body, headers: test_headers(@client))).to have_been_made
        expect(buys.last.price).to eq 7
        expect(buys.last.date).to eq Time.utc(2011, 6, 27, 18, 20, 38)
        expect(buys.last.amount).to eq BigDecimal("0.2")
        expect(buys.last.status).to eq "open"
        expect(buys.last.currency).to eq "USD"
        expect(buys.last.item).to eq "BTC"
      end
    end

    describe "#sells" do
      it "fetches sells" do
        sells = @client.sells
        expect(a_post("/api/1/generic/orders").with(body: test_body, headers: test_headers(@client))).to have_been_made
        expect(sells.last.price).to eq BigDecimal('99.0')
        expect(sells.last.date).to eq Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end

    describe "#orders" do
      it "fetches both buys and sells, with only one call" do
        orders = @client.orders
        expect(a_post("/api/1/generic/orders").with(body: test_body, headers: test_headers(@client))).to have_been_made
        expect(orders[:buys].last.price).to eq BigDecimal('7.0')
        expect(orders[:buys].last.date).to eq Time.utc(2011, 6, 27, 18, 20, 38)
        expect(orders[:sells].last.price).to eq BigDecimal('99.0')
        expect(orders[:sells].last.date).to eq Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end
  end

  describe "#buy!" do
    before do
      body = test_body({"type" => "bid", "amount_int" => "88000000", "price_int" => "89000"})
      body_market = test_body({"type" => "bid", "amount_int" => "88000000"})
      stub_post('/api/1/BTCUSD/order/add').
        with(body: body, headers: test_headers(@client, body)).
        to_return(body: fixture('buy.json'))
      stub_post('/api/1/BTCUSD/order/add').
        with(body: body_market, headers: test_headers(@client, body_market)).
        to_return(body: fixture('buy.json'))
    end

    it "should place a bid" do
      buy = @client.buy!(0.88, 0.89)
      body = test_body({"type" => "bid", "amount_int" => "88000000", "price_int" => "89000"})
      expect(a_post("/api/1/BTCUSD/order/add").with(body: body, headers: test_headers(@client, body))).to have_been_made
      expect(buy).to eq "490a214f-9a30-449f-acb8-780f9046502f"
    end

    it "should place a market bid" do
      buy = @client.buy!(0.88, :market)
      body_market = test_body({"type" => "bid", "amount_int" => "88000000"})
      expect(a_post("/api/1/BTCUSD/order/add").with(body: body_market, headers: test_headers(@client, body_market))).to have_been_made
      expect(buy).to eq "490a214f-9a30-449f-acb8-780f9046502f"
    end
  end

  describe "#sell!" do
    before do
      body = test_body({"type" => "ask", "amount_int" => "88000000", "price_int" => "8900000"})
      body_market = test_body({"type" => "ask", "amount_int" => "88000000"})

      stub_post('/api/1/BTCUSD/order/add').
        with(body: body, headers: test_headers(@client, body)).
        to_return(body: fixture('sell.json'))
      stub_post('/api/1/BTCUSD/order/add').
        with(body: body_market, headers: test_headers(@client, body_market)).
        to_return(body: fixture('sell.json'))
    end

    it "should place an ask" do
      body = test_body({"type" => "ask", "amount_int" => "88000000", "price_int" => "8900000"})
      sell = @client.sell!(0.88, 89.0)
      expect(a_post("/api/1/BTCUSD/order/add").with(body: body, headers: test_headers(@client, body))).to have_been_made
      expect(sell).to eq "a20329fe-c0d5-4378-b204-79a7800d41e7"
    end

    it "should place a market ask" do
      body_market = test_body({"type" => "ask", "amount_int" => "88000000"})
      sell = @client.sell!(0.88, :market)
      expect(a_post("/api/1/BTCUSD/order/add").with(body: body_market, headers: test_headers(@client, body_market))).to have_been_made
      expect(sell).to eq "a20329fe-c0d5-4378-b204-79a7800d41e7"
    end
  end

  describe "#cancel" do
    before do
      cancel_body = test_body({"oid" => "fda8917a-63d3-4415-b827-758408013690"})
      stub_post('/api/1/generic/orders').
        with(body: test_body, headers: test_headers(@client)).
        to_return(body: fixture('orders.json'))
      stub_post('/api/1/BTCUSD/order/cancel').
        with(body: cancel_body, headers: test_headers(@client, cancel_body)).
        to_return(body: fixture('cancel.json'))
    end

    context "with a valid oid passed" do
      it "should cancel an order" do
        cancel = @client.cancel("fda8917a-63d3-4415-b827-758408013690")
        cancel_body = test_body({"oid" => "fda8917a-63d3-4415-b827-758408013690"})
        expect(a_post("/api/1/generic/orders").with(body: test_body, headers: test_headers(@client))).to have_been_made.once
        expect(a_post('/api/1/BTCUSD/order/cancel').with(body: cancel_body, headers: test_headers(@client, cancel_body))).to have_been_made
        expect(cancel[:buys].length).to eq 0
      end
    end

    context "with an invalid oid passed" do
      it "should raise an error" do
        expect { @client.cancel(1234567890) }.to raise_error(MtGox::OrderNotFoundError)
      end
    end

    context "with an order passed" do
      it "should cancel an order" do
        cancel = @client.cancel({'oid' => "fda8917a-63d3-4415-b827-758408013690", 'type' => 2})
        body = test_body({"oid" => "fda8917a-63d3-4415-b827-758408013690"})
        expect(a_post('/api/1/BTCUSD/order/cancel').with(body: body, headers: test_headers(@client, body))).to have_been_made
        expect(cancel[:buys].length).to eq 0
        expect(cancel[:sells].last.price).to eq BigDecimal('99.0')
        expect(cancel[:sells].last.date).to eq Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end
  end

  describe "#withdraw!" do
    before do
      body = test_body({"amount_int" => "100000000", "address" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
      stub_post('/api/1/generic/bitcoin/send_simple').
        with(body: body, headers: test_headers(@client, body)).
        to_return(body: fixture('withdraw.json'))
    end

    it "should withdraw funds" do
      withdraw = @client.withdraw!(1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L")
      body = test_body({"amount_int" => "100000000", "address" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
      expect(a_post("/api/1/generic/bitcoin/send_simple").with(body: body, headers: test_headers(@client, body))).to have_been_made
      expect(withdraw).to eq "311295deadbeef390a13c038e2b8ba77feebdaed2c1a59e6e0bdf001656e1314"
    end

    it "pays attention to too big withdrawals" do
      expect {
        @client.withdraw!(10000, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L")
      }.to raise_error(MtGox::FilthyRichError)
    end
  end

  describe "nonce_type" do
    before do
      stub_post('/api/1/generic/bitcoin/address').
        to_return(body: fixture('address.json'))
    end

    it "uses nonce by default" do
      address = @client.address
      expect(a_post('/api/1/generic/bitcoin/address').with(nonce: 1321745961249676)).to have_been_made
    end

    it "is capable of using tonce" do
      @client.nonce_type = :tonce
      address = @client.address
      expect(a_post('/api/1/generic/bitcoin/address').with(tonce: 1321745961249676)).to have_been_made
    end
  end

  describe "#order_result" do
    context "for a valid order id" do
      let(:order_id) { "Zda8917a-63d3-4415-b827-758408013691" }
      let(:body) { test_body({"type" => "bid", "order" => order_id}) }

      before do
        stub_post('/api/1/generic/order/result').
          with(body: body, headers: test_headers(@client, body)).
          to_return(body: fixture('order_result.json'))
      end

      it "returns an order result" do
        order_result = @client.order_result("bid", order_id)
        expect(a_post("/api/1/generic/order/result").with(body: body, headers: test_headers(@client, body))).to have_been_made
        expect(order_result.id).to eq order_id
      end
    end
  end
end
