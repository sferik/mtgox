require 'helper'

describe Faraday::Response do
  describe 'MysqlError' do
    before do
      stub_get('/api/1/BTCUSD/trades/fetch').
        to_return(:status => 200, :body => fixture('mysql_error'))
    end

    it 'raises MtGox::MysqlError' do
      expect do
        MtGox.trades
      end.to raise_error(MtGox::MysqlError)
    end
  end

  describe 'Error' do
    before do
      stub_get('/api/1/BTCUSD/trades/fetch').
        to_return(:status => 200, :body => fixture('unknown_error.json'))
    end

    it 'raises MtGox::Error' do
      expect do
        MtGox.trades
      end.to raise_error(MtGox::Error)
    end

    describe 'UnauthorizedError' do
      before do
        stub_get('/api/1/BTCUSD/trades/fetch').
          to_return(:status => 403, :body => fixture('error.json'))
      end

      it 'raises MtGox::UnauthorizedError' do
        expect do
          MtGox.trades
        end.to raise_error(MtGox::UnauthorizedError)
      end
    end

  end
end
