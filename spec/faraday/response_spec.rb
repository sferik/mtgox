require 'helper'

describe Faraday::Response do
  describe "MysqlError" do
    before do
      stub_get('/api/1/BTCUSD/trades/fetch').
        to_return(status: 200, body: fixture('mysql_error'))
    end

    it "should raise MtGox::MysqlError" do
      lambda do
        MtGox.trades
      end.should raise_error(MtGox::MysqlError)
    end
  end

  describe "Error" do
    before do
      stub_get('/api/1/BTCUSD/trades/fetch').
        to_return(status: 200, body: fixture('unknown_error.json'))
    end

    it "should raise MtGox::Error" do
      lambda do
        MtGox.trades
      end.should raise_error(MtGox::Error)
    end
  end
end
