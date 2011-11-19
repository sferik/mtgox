require 'mtgox/version'

module MtGox
  module Configuration
    # An array of valid keys in the options hash when configuring a {MtGox::Client}
    VALID_OPTIONS_KEYS = [
      :commission,
      :key,
      :secret,
    ]

    DEFAULT_COMMISSION = 0.0065.freeze

    attr_accessor *VALID_OPTIONS_KEYS

    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.reset
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Create a hash of options and their values
    def options
      options = {}
      VALID_OPTIONS_KEYS.each{|k| options[k] = send(k)}
      options
    end

    # Reset all configuration options to defaults
    def reset
      self.commission = DEFAULT_COMMISSION
      self.key   = nil
      self.secret   = nil
      self
    end
  end
end
