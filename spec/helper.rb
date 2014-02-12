require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage(98.89)
end

require 'mtgox'
require 'base64'
require 'json'
require 'rspec'
require 'webmock/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

WebMock.disable_net_connect!(:allow => 'coveralls.io')

def a_get(path)
  a_request(:get, 'https://data.mtgox.com' + path)
end

def stub_get(path)
  stub_request(:get, 'https://data.mtgox.com' + path)
end

def a_post(path)
  a_request(:post, 'https://data.mtgox.com' + path)
end

def stub_post(path)
  stub_request(:post, 'https://data.mtgox.com' + path)
end

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

module MtGox
  module Request
  private

    def add_nonce(options)
      options.merge!(nonce_type => 1_321_745_961_249_676)
    end
  end
end

def test_headers(client, body = test_body)
  signature = Base64.strict_encode64(
    OpenSSL::HMAC.digest 'sha512',
                         Base64.decode64(client.secret),
                         body
  )
  {'Rest-Key' => client.key, 'Rest-Sign' => signature}
end

def test_body(options = {})
  options.merge!(:nonce => 1_321_745_961_249_676).collect { |k, v| "#{k}=#{v}" } * '&'
end
