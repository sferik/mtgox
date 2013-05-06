require 'faraday'
require 'json'

module Faraday
  class Response::RaiseMtGoxError < Response::Middleware
    def on_complete(env)
      if 200 == env[:status] && 'MySQL error, please retry later' == env[:body]
        raise MtGox::MysqlError, "MySQL error, please retry later"
      elsif 403 == env[:status] && JSON.load(env[:body])["result"] == "error"
        raise MtGox::UnauthorizedError, JSON.load(env[:body])["error"]
      elsif 404 != env[:status] && JSON.load(env[:body])["result"] == "error"
        raise MtGox::Error, JSON.load(env[:body])["error"]
      end
    end
  end
end
