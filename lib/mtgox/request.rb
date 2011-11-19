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
          options.merge!({:nonce => (Time.now.to_f*1000000).to_i})
          request.path = path
          request.body = options unless options.empty?
          request.headers = headers(request.body)
        end
      end
      response.body
    end

    def headers(request)
      signature = OpenSSL::HMAC.hexdigest('sha512',MtGox.secret,request.to_param)
      {'Rest-Key' => MtGox.key, 'Rest-Sign' => signature}
    end
  end
end
