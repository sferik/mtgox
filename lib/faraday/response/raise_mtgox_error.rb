require 'faraday'

module Faraday
  class Response::RaiseMtGoxError < Response::Middleware
    def on_complete(env)
      if 200 == env[:status] && 'MySQL error, please retry later' == env[:body]
        raise MtGox::MysqlError, "MySQL error, please retry later"
      elsif 403 == env[:status] && MultiJson.load(env[:body])["result"] == "error"
        raise MtGox::UnauthorizedError, MultiJson.load(env[:body])["error"]
      elsif 404 != env[:status] && MultiJson.load(env[:body])["result"] == "error"
        raise MtGox::Error, MultiJson.load(env[:body])["error"]
      end
    end
  end
end
