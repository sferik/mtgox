require 'faraday'
require 'json'

module Faraday
  class Response
    class RaiseMtGoxError < Response::Middleware
      def on_complete(env) # rubocop:disable CyclomaticComplexity
        if 200 == env[:status] && 'MySQL error, please retry later' == env[:body]
          fail(MtGox::MysqlError.new(env[:body]))
        elsif 403 == env[:status] && JSON.load(env[:body])['result'] == 'error'
          fail(MtGox::UnauthorizedError.new(JSON.load(env[:body])['error']))
        elsif 404 != env[:status] && JSON.load(env[:body])['result'] == 'error'
          fail(MtGox::Error.new(JSON.load(env[:body])['error']))
        end
      end
    end
  end
end
