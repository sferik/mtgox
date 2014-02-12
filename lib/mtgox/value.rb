require 'bigdecimal'

# In the "old API", currency- and amount-values (price, volume,...)
# were given as float. These values are likely being deprecated and
# replaced by fields of the same name with "_int" as suffix. These are
# fixed-decimal, so you have to move the decimal point yourself
# (divide). The exponent differs based on the kind of the value.

module MtGox
  module Value
    # We assume here that any other currency than :jpy uses :usd
    INT_MULTIPLIERS = {:btc => 100_000_000, :usd => 100_000, :jpy => 1000}

    # Takes a hash return by the API and convert some value_int to a
    # currency value using USD conversion rule. You can specify which
    # key to convert
    #
    # @param value [Hash] a hash from the API
    # params key [String] the key from the previous hash to convert, default to 'value_int'
    # @authenticated false
    # @return [Float]
    def value_currency(value, key = 'value_int')
      decimalify(value[key].to_i, :usd)
    end

    # Takes a hash return by the API and convert some value_int to
    # [Float] BitCoin value . You can specify which key to convert
    #
    # @param value [Hash] a hash from the API
    # params key [String] the key from the previous hash to convert, default to 'value_int'
    # @authenticated false
    # @return [Float] a float BTC value
    def value_bitcoin(value, key = 'value_int')
      decimalify(value[key], :btc)
    end

    # Convert a BigDecimal value to an int using the MtGox conversion rules.
    #
    # param decimal [BigDecimal] to convert
    # param currency [Symbol] currency conversion rule to use amongst [:btc, :usd, :jpy]
    # return an int
    def intify(decimal, currency)
      (decimal * INT_MULTIPLIERS[currency]).to_i
    end

    # Convert an int value to a decimal using the MtGox conversion rules.
    #
    # param int [Fixnum] to convert
    # param currency [Symbol] currency conversion rule to use amongst [:btc, :usd, :jpy]
    # return a [BigDecimal]
    def decimalify(int, currency)
      (BigDecimal(int.to_s) / INT_MULTIPLIERS[currency])
    end
  end
end
