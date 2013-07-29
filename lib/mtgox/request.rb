require 'base64'

module MtGox
  module Request
    def get(path, options={})
      request(:get, path, options)
    end

    def post(path, options={})
      request(:post, path, options)
    end

  private

    def request(method, path, options)
      response = connection.send(method) do |request|
        case method
        when :get
          request.url(path, options)
        when :post
          request.path = path
          request.body = body_from_options(options)
          request.headers = headers(request.body)
        end
      end
      if response.body['result'] && response.body['result'] == 'success'
        response.body['return']
      else
        response.body
      end
    end

    def headers(request)
      signature = Base64.strict_encode64(
        OpenSSL::HMAC.digest 'sha512',
        Base64.decode64(secret),
        request
      )
      {'Rest-Key' => key, 'Rest-Sign' => signature}
    end

    def body_from_options(options)
      add_nonce(options).collect{|k, v| "#{k}=#{v}"} * '&'
    end

    def add_nonce(options)
      options.merge!({self.nonce_type => (Time.now.to_f * 1000000).to_i})
    end
  end
end
