require "rails_helper"

RSpec.describe EncryptedDataSerializer do
  let(:user) { create(user) }

  describe "#load" do
    it "should return nil if value is nil" do
      expect(EncryptedDataSerializer.new.load(nil)).to be_nil
    end

    it "should decode value" do
      allow(CipherService).to receive(:decrypt)
      expect(Base64).to receive(:decode64).with(111)
      EncryptedDataSerializer.new.load(111)
    end

    it "should return decrypt value" do
      decoded_value = double
      allow(Base64).to receive(:decode64).with(111) { decoded_value }
      allow(CipherService).to receive(:decrypt).with(decoded_value) { 'decrypted_value' }
      expect(EncryptedDataSerializer.new.load(111)).to eq('decrypted_value')
    end
  end

  describe "#dump" do
    it "should encrypt value" do
      expect(CipherService).to receive(:encrypt).with(111)
      allow(Base64).to receive(:encode64)
      EncryptedDataSerializer.new.dump(111)
    end

    it "should return encoded value" do
      decrypted_value = double
      allow(CipherService).to receive(:encrypt).with(111) { decrypted_value }
      allow(Base64).to receive(:encode64).with(decrypted_value) { 'encoded_value' }
      expect(EncryptedDataSerializer.new.dump(111)).to eq('encoded_value')
    end
  end
end
