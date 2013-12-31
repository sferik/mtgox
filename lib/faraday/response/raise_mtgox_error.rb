require 'faraday'
require 'json'

module Faraday
  class Response::RaiseMtGoxError < Response::Middleware
    def on_complete(env) # rubocop:disable CyclomaticComplexity
      if 200 == env[:status] && 'MySQL error, please retry later' == env[:body]
        fail(MtGox::MysqlError, env[:body])
      elsif 403 == env[:status] && JSON.load(env[:body])['result'] == 'error'
        fail(MtGox::UnauthorizedError, JSON.load(env[:body])['error'])
      elsif 404 != env[:status] && JSON.load(env[:body])['result'] == 'error'
        fail(MtGox::Error, JSON.load(env[:body])['error'])
      end
    end
  end
end
