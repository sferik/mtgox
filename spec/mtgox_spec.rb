require 'helper'

describe MtGox do
  describe ".new" do
    it "should return a MtGox::Client" do
      MtGox.new.should be_a MtGox::Client
    end
  end

  describe ".configure" do
    it "should set 'username' and 'password'" do
      MtGox.configure do |config|
        config.username = "username"
        config.password = "password"
      end

      MtGox.username.should == "username"
      MtGox.password.should == "password"
    end
  end

end
