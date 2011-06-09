module MtGox
  module Request
    def get(path, options={})
      request(:get, path, options)
    end
    def post(path, body={})
      response = connection.post(path) do |request|
        request.body = body
        request.url(path)
      end
      response.body
    end

    private

    def request(method, path, options)
      response = connection.send(method) do |request|
        request.url(path, options)
      end
      response.body
    end
  end
end
