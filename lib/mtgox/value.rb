# In the "old API", currency- and amount-values (price, volume,...)
# were given as float. These values are likely being deprecated and
# replaced by fields of the same name with "_int" as suffix. These are
# fixed-decimal, so you have to move the decimal point yourself
# (divide). The exponent differs based on the kind of the value.

module MtGox
  module Value
    # We assume here that any other currency than :jpy uses :usd
    INT_MULTIPLIERS = {btc: 100000000, usd: 100000, jpy: 1000}

    def value_currency(value, key = 'value_int')
      floatify(value[key].to_i, :usd)
    end

    def value_bitcoin(value, key = 'value_int')
      floatify(value[key], :btc)
    end

    def intify(float, currency)
      (float * INT_MULTIPLIERS[currency]).to_i
    end

    # Unused yet
    # def floatify(int, currency)
    #   (int.to_f / INT_MULTIPLIERS[currency])
    # end
  end
end
