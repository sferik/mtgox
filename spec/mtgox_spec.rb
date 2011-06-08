require 'helper'

describe MtGox do
  describe ".new" do
    it "should return a MtGox::Client" do
      MtGox.new.should be_a MtGox::Client
    end
  end
end
