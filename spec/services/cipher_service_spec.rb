require "rails_helper"

RSpec.describe CipherService do

  let(:cipher) { double(OpenSSL).as_null_object }

  before do
    allow(OpenSSL::Cipher).to receive(:new).with(CipherService::ALGORITHM) { cipher }
    allow(ENV).to receive(:[]).with("SECRET_KEY") { 'super secret' }
  end

  describe ".encrypt" do
    it "should set encrypt state for cipher" do
      expect(cipher).to receive(:encrypt)
      CipherService.encrypt('data')
    end

    it "should set key for cipher" do
      expect(cipher).to receive(:key=).with("super secret")
      CipherService.encrypt('data')
    end

    it "should return encrypted data" do
      allow(cipher).to receive(:update).with('data') { "encrypted " }
      allow(cipher).to receive(:final) { "data" }
      expect(CipherService.encrypt('data')).to eq("encrypted data")
    end
  end

  describe ".decrypt" do
    it "should set decrypt state for cipher" do
      expect(cipher).to receive(:decrypt)
      CipherService.decrypt('data')
    end

    it "should set key for cipher" do
      expect(cipher).to receive(:key=).with("super secret")
      CipherService.decrypt('data')
    end

    it "should return decrypted data" do
      allow(cipher).to receive(:update).with('data') { "decrypted " }
      allow(cipher).to receive(:final) { "data" }
      expect(CipherService.decrypt('data')).to eq("decrypted data")
    end
  end
end
