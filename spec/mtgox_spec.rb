require 'helper'

describe MtGox do
  describe ".new" do
    it "should return a MtGox::Client" do
      MtGox.new.should be_a MtGox::Client
    end
  end

  describe ".configure" do
    it "should set 'name' and 'pass'" do
      MtGox.configure do |config|
        config.name = "username"
        config.pass = "password"
      end

      MtGox.name.should == "username"
      MtGox.pass.should == "password"
    end
  end

end
