require 'faraday'
require 'json'

module MtGox
  module Response
    class ParseJson < Faraday::Response::Middleware
      def parse(body)
        case body
        when /\A^\s*$\z/, nil
          nil
        else
          JSON.load(body)
        end
      end

      def on_complete(env)
        if respond_to?(:parse)
          env[:body] = parse(env[:body]) unless [204, 301, 302, 304].include?(env[:status])
        end
      end
    end
  end
end
