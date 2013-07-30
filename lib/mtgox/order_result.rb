module MtGox
  class OrderResult
    include Value

    def initialize(json)
      @json = json
    end

    def id
      @json["order_id"]
    end

    def trades
      @json["trades"].map{|t| Trade.new(coerce_trade(t)) }
    end

    def total_spent
      to_decimal "total_spent", @json
    end

    def total_amount
      to_decimal "total_amount", @json
    end

    def avg_cost
      to_decimal "avg_cost", @json
    end

    private

    def to_decimal(key, json)
      data = json.fetch(key)
      decimalify(data["value_int"], currency_lookup[data["currency"]])
    end

    def currency_lookup
      { "USD" => :usd, "BTC" => :btc, "JPY" => :jpy }
    end

    def coerce_trade(hash)
      {
        "tid"    => hash["trade_id"],
        "date"   => Time.parse(hash["date"]),
        "amount" => to_decimal("amount", hash),
        "price"  => to_decimal("price", hash)
      }
    end
  end
end
