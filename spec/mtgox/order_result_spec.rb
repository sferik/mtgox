require 'helper'

describe MtGox::OrderResult do
  let(:json) { JSON.parse(File.read(fixture("order_result.json")))["return"] }
  subject { described_class.new(json) }

  describe '#total_spent' do
    it "returns a decimal" do
      expect(subject.total_spent).to eq BigDecimal.new('10.08323')
    end
  end

  describe '#total_amount' do
    it "returns a decimal" do
      expect(subject.total_amount).to eq BigDecimal.new('0.10')
    end
  end

  describe '#avg_cost' do
    it "returns a decimal" do
      expect(subject.avg_cost).to eq BigDecimal.new('100.83230')
    end
  end

  describe "#trades" do
    it "returns an array of Trade objects" do
      trade = subject.trades.first
      expect(trade.id).to eq 1375134017519310
      expect(trade.date).to eq Time.parse('2013-07-29 21:40:17 UTC')
      expect(trade.amount).to eq BigDecimal.new("0.10000000")
      expect(trade.price).to eq BigDecimal.new("100.83227")
    end
  end
end
