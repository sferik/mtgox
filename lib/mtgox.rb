require 'mtgox/client'

module MtGox
  ORDER_TYPES = {:buy=>2, :sell=>1}
  STATUS_TYPES = {:active=>1, :not_enough_funds=>2}
  
  class << self
  	attr_accessor :name, :pass
  	def configure
  	  yield self
  	end
  end
  
  # Alias for MtGox::Client.new
  #
  # @return [MtGox::Client]
  def self.new
    MtGox::Client.new
  end

  # Delegate to MtGox::Client
  def self.method_missing(method, *args, &block)
    return super unless new.respond_to?(method)
    new.send(method, *args, &block)
  end

  def self.respond_to?(method, include_private=false)
    new.respond_to?(method, include_private) || super(method, include_private)
  end
end
