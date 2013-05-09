require 'bigdecimal'

module MtGox
  class Lag
    attr_accessor :microseconds, :seconds, :text, :length

    def initialize(lag=nil, lag_secs=nil, lag_text=nil, length=nil)
      self.microseconds = lag.to_i
      self.seconds = BigDecimal(lag_secs.to_s)
      self.text = lag_text
      self.length = length.to_i
    end
  end
end
