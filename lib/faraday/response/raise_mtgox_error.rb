require 'faraday'

module Faraday
  class Response::RaiseMtGoxError < Response::Middleware
    def on_complete(env)
      if 200 == env[:status] && 'MySQL error, please retry later' == env[:body]
        raise MtGox::MysqlError, "MySQL error, please retry later"
      end
    end
  end
end
