require 'faraday'
require 'json'

module MtGox
  module Response
    class ParseJson < Faraday::Response::Middleware
      def parse(body)
        JSON.load(body) unless body =~ /\A^\s*$\z/
      end

      def on_complete(env)
        if respond_to?(:parse)
          env[:body] = parse(env[:body]) unless [204, 301, 302, 304].include?(env[:status])
        end
      end
    end
  end
end
