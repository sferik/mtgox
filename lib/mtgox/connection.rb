require 'faraday_middleware'

module MtGox
  module Connection
    private

    def connection
      options = {
        :ssl => {:verify => false},
        :url => 'https://mtgox.com',
        :headers  => {:user_agent => "MtGoxGem"}
      }

      Faraday.new(options) do |connection|
        connection.use Faraday::Request::UrlEncoded
        connection.use Faraday::Response::RaiseError
        connection.use Faraday::Response::Rashify
        connection.use Faraday::Response::ParseJson
        connection.adapter(Faraday.default_adapter)
      end
    end
  end
end
