require 'helper'

describe MtGox::Client do
  before do
    @client = MtGox::Client.new
    MtGox.configure {|c| c.name="my_name"; c.pass="my_password"}
  end

  describe '#ticker' do
    before do
      stub_get('/code/data/ticker.php').
        to_return(:status => 200, :body => fixture('ticker.json'))
    end

    it "should fetch the ticker" do
      ticker = @client.ticker
      a_get('/code/data/ticker.php').should have_been_made
      ticker.last.should == 26.5
    end
  end

  describe 'depth methods' do
    before :each do
      stub_get('/code/data/getDepth.php').
        to_return(:status => 200, :body => fixture('depth.json'))
    end

    describe '#asks' do
      it "should fetch open asks" do
        asks = @client.asks
        a_get('/code/data/getDepth.php').should have_been_made
        asks.last.should == [45, 593.28]
      end

      it "should be sorted in price-ascending order" do
        asks = @client.asks
        asks.sort_by {|x| x[0]}.should == asks
      end

    end

    describe "#bids" do
      it "should fetch open bids" do
        bids = @client.bids
        a_get('/code/data/getDepth.php').should have_been_made
        bids.last.should == [19.1, 1]
      end

      it "should be sorted in price-descending order" do
        bids = @client.bids
        bids.sort_by {|x| x[0]}.reverse.should == bids
      end

    end

    describe "#offers" do
      it "should fetch both bids and asks, making only 1 network request" do
        offers = @client.offers
        a_get('/code/data/getDepth.php').should have_been_made.once
        offers.asks.last.should == [45, 593.28]
        offers.bids.last.should == [19.1, 1]
      end
    end

  end

  describe '#trades' do
    before do
      stub_get('/code/data/getTrades.php').
        to_return(:status => 200, :body => fixture('trades.json'))
    end

    it "should fetch trades" do
      trades = @client.trades
      a_get('/code/data/getTrades.php').should have_been_made
      trades.last.date.should == Time.utc(2011, 6, 8, 9, 51, 57)
      trades.last.price.should == 26.6099
      trades.last.amount.should == 1.37
      trades.last.tid.should == "129606"
    end

    it "should be sorted in chronological order" do
      trades = @client.trades
      trades.sort_by(&:date).should == trades
    end
  end

  describe '#balance' do
    before do
      stub_post('/code/getFunds.php').
        to_return(:status => 200, :body => fixture('funds.json'))
    end

    it "should fetch balance" do
      balance = @client.balance
      a_post("/code/getFunds.php").should have_been_made
      balance.usds.should == 3.7
      balance.btcs.should == 22.0
    end
  end

  describe "order methods" do
    before :each do
      stub_post('/code/getOrders.php').
        to_return(:status => 200, :body => fixture('orders.json'))
    end

    describe "#buys" do
      it "should fetch orders" do
        buys = @client.buys
        a_post("/code/getOrders.php").should have_been_made
        buys.last.price.should == 14
      end
    end

    describe "#sells" do
      it "should fetch sells" do
        sells = @client.sells
        a_post("/code/getOrders.php").should have_been_made
        sells.last.price.should == 29.3
      end
    end

    describe "#orders" do
      it "should fetch both buys and sells, with only one call" do
        orders = @client.orders
        a_post("/code/getOrders.php").should have_been_made.once
        orders.last.price.should == 29.3
      end
    end
  end

  describe "#buy!" do
    before do
      stub_post('/code/buyBTC.php').
        to_return(:status => 200, :body => fixture('buy.json'))
    end

    it "should place a bid" do
      @client.buy!(0.88, 0.89)
      a_post("/code/buyBTC.php").
        with(:body => {"name" => "my_name", "pass" => "my_password", "amount" => "0.88", "price" => "0.89"}).
        should have_been_made
    end
  end

  describe "#sell!" do
    before do
      stub_post('/code/sellBTC.php').
        to_return(:status => 200, :body => fixture('sell.json'))
    end

    it "should place an ask" do
      @client.sell!(0.88, 89.0)
      a_post("/code/sellBTC.php").
        with(:body => {"name" => "my_name", "pass" => "my_password", "amount" => "0.88", "price" => "89.0"}).
        should have_been_made
    end
  end

  describe "#cancel" do
    before do
      stub_post('/code/getOrders.php').
        to_return(:status => 200, :body => fixture('orders.json'))
      stub_post('/code/cancelOrder.php').
        to_return(:status => 200, :body => fixture('cancel.json'))
    end

    context "with a valid oid passed" do
      it "should cancel an order" do
        @client.cancel(929284)
        a_post("/code/getOrders.php").should have_been_made.once
        a_post('/code/cancelOrder.php').
          with(:body => {"name" => "my_name", "pass" => "my_password", "oid" => "929284", "type" => "2"}).
          should have_been_made
      end
    end

    context "with an invalid oid passed" do
      it "should raise an error" do
        lambda do
          @client.cancel(1234567890)
        end.should raise_error(Faraday::Error::ResourceNotFound)
      end
    end

    context "with an order passed" do
      it "should cancel an order" do
        @client.cancel({'oid' => "929284", 'type' => 2})
        a_post('/code/cancelOrder.php').
          with(:body => {"name" => "my_name", "pass" => "my_password", "oid" => "929284", "type" => "2"}).
          should have_been_made
      end
    end
  end

  describe "#withdraw!" do
    before do
      stub_post('/code/withdraw.php').
        to_return(:status => 200, :body => fixture('withdraw.json'))
    end

    it "should withdraw funds" do
      @client.withdraw!(1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L")
      a_post("/code/withdraw.php").
        with(:body => {"name" => "my_name", "pass" => "my_password", "group1" => "BTC", "amount" => "1.0", "btca" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"}).
        should have_been_made
    end
  end

end
