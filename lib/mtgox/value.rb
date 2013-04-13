# In the "old API", currency- and amount-values (price, volume,...)
# were given as float. These values are likely being deprecated and
# replaced by fields of the same name with "_int" as suffix. These are
# fixed-decimal, so you have to move the decimal point yourself
# (divide). The exponent differs based on the kind of the value.

#
# Conversion table :
# - BTC : 1e8
# - USD : 1e5
#
module MtGox
  module Value

    def value_currency(value)
      value['value_int'].to_i / 100000.0
    end
    def value_bitcoin(value)
      value['value_int'].to_i / 100000000.0
    end
  end
end
