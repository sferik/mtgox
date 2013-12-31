require 'helper'

describe MtGox do
  describe '.new' do
    it 'returns a MtGox::Client' do
      expect(MtGox.new).to be_a MtGox::Client
    end
  end

  describe '.configure' do
    it 'sets key and secret' do
      MtGox.configure do |config|
        config.key = 'key'
        config.secret = 'secret'
      end

      expect(MtGox.key).to eq 'key'
      expect(MtGox.secret).to eq 'secret'
    end

    it 'allows setting nonce type' do
      expect(MtGox.nonce_type).to eq(:nonce)
      MtGox.configure do |config|
        config.nonce_type = :tonce
      end
      expect(MtGox.nonce_type).to eq(:tonce)
    end
  end

end
