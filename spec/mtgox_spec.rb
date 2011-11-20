require 'helper'

describe MtGox do
  describe ".new" do
    it "should return a MtGox::Client" do
      MtGox.new.should be_a MtGox::Client
    end
  end

  describe ".configure" do
    it "should set 'key' and 'secret'" do
      MtGox.configure do |config|
        config.key = "key"
        config.secret = "secret"
      end

      MtGox.key.should == "key"
      MtGox.secret.should == "secret"
    end
  end

end
