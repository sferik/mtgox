require 'helper'

describe Faraday::Response do
  describe "MysqlError" do
    before do
      stub_get('/api/1/BTCUSD/trades/fetch').
        to_return(status: 200, body: fixture('mysql_error'))
    end

    it "should raise MtGox::MysqlError" do
      expect { MtGox.trades }.to raise_error(MtGox::MysqlError)
    end
  end

  describe "Error" do
    before do
      stub_get('/api/1/BTCUSD/trades/fetch').
        to_return(status: 200, body: fixture('unknown_error.json'))
    end

    it "should raise MtGox::Error" do
      expect { MtGox.trades }.to raise_error(MtGox::Error)
    end

    describe "UnauthorizedError" do
      before do
        @client = MtGox::Client.new
        body = test_body({"amount_int" => "100000000", "address" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
        stub_post('/api/1/generic/bitcoin/send_simple').
          with(body: body, headers: test_headers(body)).
          to_return(status: 403, body: fixture('error.json'))
      end

      it "should raise MtGox::UnauthorizedError" do
        expect { @client.withdraw!(1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L") }.
          to raise_error(MtGox::UnauthorizedError)
      end
    end

  end
end
