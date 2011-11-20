module MtGox
  module Request
    def get(path, options={})
      request(:get, path, options)
    end

    def post(path, options={})
      request(:post, path, options)
    end

    def test_headers(body=test_body)
      headers(body).merge!({'Accept'=>'application/json',
                             'Content-Type'=>'application/x-www-form-urlencoded',
                             'User-Agent'=>'mtgox gem 0.7.1'})
    end if MTGOX_ENV == :test

    def test_body(options={})
      body_from_options(options)
    end if MTGOX_ENV == :test

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
      response.body
    end

    def headers(request)
      signature = Base64.strict_encode64(OpenSSL::HMAC.digest 'sha512',
                                         Base64.decode64(MtGox.secret),
                                         request)
      {'Rest-Key' => MtGox.key, 'Rest-Sign' => signature}
    end

    def body_from_options(options)
      add_nonce(options).collect do |k,v|
        "#{k}=#{v}"
      end * '&'
    end

    def add_nonce(options)
      options.merge!({:nonce => (Time.now.to_f*1000000).to_i})
    end unless MTGOX_ENV == :test

    def add_nonce(options)
      options.merge!({:nonce => 1321745961249676})
    end if MTGOX_ENV == :test
  end
end
