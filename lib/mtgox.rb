MTGOX_ENV ||= :production
require 'mtgox/client'
require 'mtgox/configuration'
require 'mtgox/error'

module MtGox
  extend Configuration
  class << self
    # Alias for MtGox::Client.new
    #
    # @return [MtGox::Client]
    def new
      MtGox::Client.new
    end

    # Delegate to MtGox::Client
    def method_missing(method, *args, &block)
      return super unless new.respond_to?(method)
      new.send(method, *args, &block)
    end

    def respond_to?(method, include_private=false)
      new.respond_to?(method, include_private) || super(method, include_private)
    end
  end
end
