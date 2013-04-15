require 'helper'

describe MtGox::Client do
  before do
    @client = MtGox::Client.new
    MtGox.configure do |config|
      config.key = "key"
      config.secret = "secret"
    end
  end

  describe '#address' do
    before do
      stub_post('/api/1/generic/bitcoin/address').
        to_return(status: 200, body: fixture('address.json'))
    end

    it "should fetch a deposit address" do
      address = @client.address
      a_post('/api/1/generic/bitcoin/address').
        should have_been_made
      address.should == '17A1vbzQ39o8cGNnpqx8UvXNrhqwAEP8wY'
    end
  end

  describe '#address' do
    before do
      stub_post('/api/1/generic/idkey').
        to_return(status: 200, body: fixture('idkey.json'))
    end

    it "should fetch a deposit address" do
      key = @client.idkey
      a_post('/api/1/generic/idkey').
        should have_been_made
      key.should == 'YCKvmyU4QsaHEqM/AvKlqAAAAABRbR5y0vCn1roteQx/Ux/lyLF27X8Em1e4AN/2etPECzIT6dU'
    end
  end

  describe '#ticker' do
    before do
      stub_get('/api/1/BTCUSD/ticker').
        to_return(status: 200, body: fixture('ticker.json'))
    end

    it "should fetch the ticker" do
      ticker = @client.ticker
      a_get('/api/1/BTCUSD/ticker').
        should have_been_made
      ticker.buy.should  == 5.53587
      ticker.sell.should == 5.56031
      ticker.high.should == 5.70653
      ticker.low.should == 5.4145
      ticker.price.should == 5.5594
      ticker.volume.should  == 55829.58960346
      ticker.vwap.should == 5.61048
      ticker.avg.should == 5.56112
    end
  end

  describe 'depth methods' do
    before :each do
      stub_get('/api/1/BTCUSD/depth/fetch').
        to_return(status: 200, body: fixture('depth.json'))
    end

    describe '#asks' do
      it "should fetch open asks" do
        asks = @client.asks
        a_get('/api/1/BTCUSD/depth/fetch').
          should have_been_made
        asks.first.price.should == 114
        asks.first.eprice.should == 114.74584801207851
        asks.first.amount.should == 0.43936758
      end

      it "should be sorted in price-ascending order" do
        asks = @client.asks
        asks.sort_by{|ask| ask.price}.should == asks
      end

    end

    describe "#bids" do
      it "should fetch open bids" do
        bids = @client.bids
        a_get('/api/1/BTCUSD/depth/fetch').
          should have_been_made
        bids.first.price.should == 113.0
        bids.first.eprice.should == 112.2655
        bids.first.amount.should == 124.69802063
      end

      it "should be sorted in price-descending order" do
        bids = @client.bids
        bids.sort_by{|bid| bid.price}.reverse.should == bids
      end
    end

    describe "#offers" do
      it "should fetch both bids and asks, with only one call" do
        offers = @client.offers
        a_get('/api/1/BTCUSD/depth/fetch').
          should have_been_made.once
        offers[:asks].first.price.should == 114
        offers[:asks].first.eprice.should == 114.74584801207851
        offers[:asks].first.amount.should == 0.43936758
        offers[:bids].first.price.should == 113.0
        offers[:bids].first.eprice.should == 112.2655
        offers[:bids].first.amount.should == 124.69802063
      end
    end

    describe '#min_ask' do
      it "should fetch the lowest priced ask" do
        min_ask = @client.min_ask
        a_get('/api/1/BTCUSD/depth/fetch').
          should have_been_made.once
        min_ask.price.should == 114
        min_ask.eprice.should == 114.74584801207851
        min_ask.amount.should == 0.43936758
      end
    end

    describe '#max_bid' do
      it "should fetch the highest priced bid" do
        max_bid = @client.max_bid
        a_get('/api/1/BTCUSD/depth/fetch').
          should have_been_made.once
        max_bid.price.should == 113
        max_bid.eprice.should == 112.2655
        max_bid.amount.should == 124.69802063
      end
    end

  end

  describe '#trades' do
    before do
      stub_get('/api/1/BTCUSD/trades/fetch').
        to_return(status: 200, body: fixture('trades.json'))
    end

    it "should fetch trades" do
      trades = @client.trades
      a_get('/api/1/BTCUSD/trades/fetch').
        should have_been_made
      trades.last.date.should == Time.utc(2013, 4, 12, 15, 20, 3)
      trades.last.price.should == 73.19258
      trades.last.amount.should == 0.94043572
      trades.last.id.should == 1365780003374123
    end
  end

  describe '#balance' do
    before do
      stub_post('/api/1/generic/info').
        with(body: test_body, headers: test_headers).
        to_return(status: 200, body: fixture('info.json'))
    end

    it "should fetch balance" do
      balance = @client.balance
      a_post("/api/1/generic/info").
        with(body: test_body, headers: test_headers).
        should have_been_made
      balance.first.currency.should == "BTC"
      balance.first.amount.should == 42.0
      balance.last.currency.should == "EUR"
      balance.last.amount.should == 23.0
    end
  end

  describe "order methods" do
    before :each do
      stub_post('/api/1/generic/orders').
        with(body: test_body, headers: test_headers).
        to_return(status: 200, body: fixture('orders.json'))
    end

    describe "#buys" do
      it "should fetch orders" do
        buys = @client.buys
        a_post("/api/1/generic/orders").
          with(body: test_body, headers: test_headers).
          should have_been_made
        buys.last.price.should == 7
        buys.last.date.should == Time.utc(2011, 6, 27, 18, 20, 38)
      end
    end

    describe "#sells" do
      it "should fetch sells" do
        sells = @client.sells
        a_post("/api/1/generic/orders").
          with(body: test_body, headers: test_headers).
          should have_been_made
        sells.last.price.should == 99.0
        sells.last.date.should == Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end

    describe "#orders" do
      it "should fetch both buys and sells, with only one call" do
        orders = @client.orders
        a_post("/api/1/generic/orders").
          with(body: test_body, headers: test_headers).
          should have_been_made
        orders[:buys].last.price.should == 7.0
        orders[:buys].last.date.should == Time.utc(2011, 6, 27, 18, 20, 38)
        orders[:sells].last.price.should == 99.0
        orders[:sells].last.date.should == Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end
  end

  describe "#buy!" do
    before do
      body = test_body({"type" => "bid", "amount_int" => "88000000", "price_int" => "89000"})
      stub_post('/api/1/BTCUSD/order/add').
        with(body: body, headers: test_headers(body)).
        to_return(status: 200, body: fixture('buy.json'))
    end

    it "should place a bid" do
      buy = @client.buy!(0.88, 0.89)
      body = test_body({"type" => "bid", "amount_int" => "88000000", "price_int" => "89000"})
      a_post("/api/1/BTCUSD/order/add").
        with(body: body, headers: test_headers(body)).
        should have_been_made
      buy.should == "490a214f-9a30-449f-acb8-780f9046502f"
    end
  end

  describe "#sell!" do
    before do
      body = test_body({"type" => "ask", "amount_int" => "88000000", "price_int" => "8900000"})
      stub_post('/api/1/BTCUSD/order/add').
        with(body: body, headers: test_headers(body)).
        to_return(status: 200, body: fixture('sell.json'))
    end

    it "should place an ask" do
      body = test_body({"type" => "ask", "amount_int" => "88000000", "price_int" => "8900000"})
      sell = @client.sell!(0.88, 89.0)
      a_post("/api/1/BTCUSD/order/add").
        with(body: body, headers: test_headers(body)).
        should have_been_made
      sell.should == "a20329fe-c0d5-4378-b204-79a7800d41e7"
    end
  end

  describe "#cancel" do
    before do
      cancel_body = test_body({"oid" => "fda8917a-63d3-4415-b827-758408013690"})
      stub_post('/api/1/generic/orders').
        with(body: test_body, headers: test_headers).
        to_return(status: 200, body: fixture('orders.json'))
      stub_post('/api/1/BTCUSD/order/cancel').
        with(body: cancel_body, headers: test_headers(cancel_body)).
        to_return(status: 200, body: fixture('cancel.json'))
    end

    context "with a valid oid passed" do
      it "should cancel an order" do
        cancel = @client.cancel("fda8917a-63d3-4415-b827-758408013690")
        cancel_body = test_body({"oid" => "fda8917a-63d3-4415-b827-758408013690"})
        a_post("/api/1/generic/orders").
          with(body: test_body, headers: test_headers).
          should have_been_made.once
        a_post('/api/1/BTCUSD/order/cancel').
          with(body: cancel_body, headers: test_headers(cancel_body)).
          should have_been_made
        cancel[:buys].length.should == 0
      end
    end

    context "with an invalid oid passed" do
      it "should raise an error" do
        expect { @client.cancel(1234567890) }.to raise_error(Faraday::Error::ResourceNotFound)
      end
    end

    context "with an order passed" do
      it "should cancel an order" do
        cancel = @client.cancel({'oid' => "fda8917a-63d3-4415-b827-758408013690", 'type' => 2})
        body = test_body({"oid" => "fda8917a-63d3-4415-b827-758408013690"})
        a_post('/api/1/BTCUSD/order/cancel').
          with(body: body, headers: test_headers(body)).
          should have_been_made
        cancel[:buys].length.should == 0
        cancel[:sells].last.price.should == 99.0
        cancel[:sells].last.date.should == Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end
  end

  describe "#withdraw!" do
    before do
      body = test_body({"amount_int" => "100000000", "address" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
      stub_post('/api/1/generic/bitcoin/send_simple').
        with(body: body, headers: test_headers(body)).
        to_return(status: 200, body: fixture('withdraw.json'))
    end

    it "should withdraw funds" do
      withdraw = @client.withdraw!(1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L")
      body = test_body({"amount_int" => "100000000", "address" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
      a_post("/api/1/generic/bitcoin/send_simple").
        with(body: body, headers: test_headers(body)).
        should have_been_made
      withdraw.should == "311295deadbeef390a13c038e2b8ba77feebdaed2c1a59e6e0bdf001656e1314"
    end

    it "pays attention to too big withdrawals" do
      lambda { @client.withdraw!(10000, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L") }.
        should raise_error(MtGox::FilthyRichError)
    end
  end
end
