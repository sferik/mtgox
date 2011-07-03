require 'faraday'
require 'faraday/response/raise_mtgox_error'
require 'faraday_middleware'
require 'mtgox/version'

module MtGox
  module Connection
    private

    def connection
      options = {
        :headers  => {
          :accept => 'application/json',
          :user_agent => "mtgox gem #{MtGox::VERSION}",
        },
        :ssl => {:verify => false},
        :url => 'https://mtgox.com',
      }

      Faraday.new(options) do |connection|
        connection.use Faraday::Request::UrlEncoded
        connection.use Faraday::Response::RaiseError
        connection.use Faraday::Response::Rashify
        connection.use Faraday::Response::ParseJson
        connection.use Faraday::Response::RaiseMtGoxError
        connection.adapter(Faraday.default_adapter)
      end
    end
  end
end
