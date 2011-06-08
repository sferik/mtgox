require 'helper'

describe MtGox::Client do
  before do
    @client = MtGox::Client.new
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

  describe '#asks' do
    before do
      stub_get('/code/data/getDepth.php').
        to_return(:status => 200, :body => fixture('depth.json'))
    end

    it "should fetch open asks" do
      asks = @client.asks
      a_get('/code/data/getDepth.php').should have_been_made
      asks.last.should == [45, 593.28]
    end
  end

  describe '#bids' do
    before do
      stub_get('/code/data/getDepth.php').
        to_return(:status => 200, :body => fixture('depth.json'))
    end

    it "should fetch open bids" do
      bids = @client.bids
      a_get('/code/data/getDepth.php').should have_been_made
      bids.last.should == [19.1, 1]
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
      trades.last.date.should == Time.local(2011, 6, 8, 2, 51, 57)
      trades.last.price.should == 26.6099
      trades.last.amount.should == 1.37
      trades.last.tid.should == "129606"
    end
  end
end
