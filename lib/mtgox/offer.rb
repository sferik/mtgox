module MtGox
  class Offer
    attr_accessor :amount, :price

    def initialize(attributes={})
      attributes.each_pair do |key, value|
        self.send(:"#{key}=", value) if self.respond_to?(:"#{key}=")
      end
    end

  end
end
