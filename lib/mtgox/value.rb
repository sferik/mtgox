# In the "old API", currency- and amount-values (price, volume,...)
# were given as float. These values are likely being deprecated and
# replaced by fields of the same name with "_int" as suffix. These are
# fixed-decimal, so you have to move the decimal point yourself
# (divide). The exponent differs based on the kind of the value.

module MtGox
  module Value
    # We assume here that any other currency than :jpy uses :usd
    INT_MULTIPLIERS = {btc: 100000000, usd: 100000, jpy: 1000}

    # Takes a hash return by the API and convert some value_int to a
    # currency value using USD conversion rule. You can specify which
    # key to convert
    #
    # @param value [Hash] a hash from the API
    # params key [String] the key from the previous hash to convert, default to 'value_int'
    # @authenticated false
    # @return [Float]
    def value_currency(value, key = 'value_int')
      floatify(value[key].to_i, :usd)
    end

    # Takes a hash return by the API and convert some value_int to
    # [Float] BitCoin value . You can specify which key to convert
    #
    # @param value [Hash] a hash from the API
    # params key [String] the key from the previous hash to convert, default to 'value_int'
    # @authenticated false
    # @return [Float] a float BTC value
    def value_bitcoin(value, key = 'value_int')
      floatify(value[key], :btc)
    end

    # Convert a float value to an int using the MtGox conversion rules.
    #
    # param float [Float] to convert
    # param currency [Symbol] currency conversion rule to use amongst [:btc, :usd, :jpy]
    # return an int
    def intify(float, currency)
      (float * INT_MULTIPLIERS[currency]).to_i
    end

    # Convert an int value to a float using the MtGox conversion rules.
    #
    # param int [Fixnum] to convert
    # param currency [Symbol] currency conversion rule to use amongst [:btc, :usd, :jpy]
    # return a [Float]
    def floatify(int, currency)
      (int.to_f / INT_MULTIPLIERS[currency])
    end
  end
end
