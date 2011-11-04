require 'helper'

describe Faraday::Response do
  before do
    stub_get('/api/0/data/getTrades.php').
      to_return(:status => 200, :body => fixture('mysql_error'))
  end

  it "should raise MtGox::MysqlError" do
    lambda do
      MtGox.trades
    end.should raise_error(MtGox::MysqlError)
  end
end
