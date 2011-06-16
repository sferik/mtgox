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
end
