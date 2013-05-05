require 'faraday'
require 'faraday/request/url_encoded'
require 'faraday/response/raise_error'
require 'faraday/response/raise_mtgox_error'
require 'mtgox/response/parse_json'
require 'mtgox/version'

module MtGox
  module Connection
  private

    def connection
      options = {
        headers:  {
          accept: 'application/json',
          user_agent: "mtgox gem #{MtGox::Version}",
        },
        url: 'https://data.mtgox.com',
      }

      Faraday.new(options) do |connection|
        connection.request :url_encoded
        connection.use Faraday::Response::RaiseError
        connection.use MtGox::Response::ParseJson
        connection.use Faraday::Response::RaiseMtGoxError
        connection.adapter(Faraday.default_adapter)
      end
    end
  end
end
