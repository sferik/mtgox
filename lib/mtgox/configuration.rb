require 'mtgox/version'
require 'bigdecimal'

module MtGox
  module Configuration
    # An array of valid keys in the options hash when configuring a {MtGox::Client}
    VALID_OPTIONS_KEYS = [
      :commission,
      :key,
      :secret,
      :nonce_type
    ]

    DEFAULT_COMMISSION = BigDecimal('0.0065').freeze
    DEFAULT_NONCE_TYPE = :nonce

    attr_accessor(*VALID_OPTIONS_KEYS)

    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.reset
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Reset all configuration options to defaults
    def reset
      self.commission = DEFAULT_COMMISSION
      self.key = nil
      self.secret = nil
      self
    end

    def nonce_type
      @nonce_type || DEFAULT_NONCE_TYPE
    end
  end
end
