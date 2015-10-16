require 'rails_helper'

RSpec.describe ClientType, type: :model do

  let(:company) { create :company }
  let(:client_type) { create :client_type, company: company }

  context 'validations' do
    context 'unique name' do
      it 'is valid even when another deleted client_type exists' do
        client_type.destroy
        new_client_type = build :client_type, company: company, name: client_type.name
        expect(new_client_type).to be_valid
      end
    end
  end

  context 'locked' do
    it 'returns false if it has a user set name' do
      expect(client_type.locked).to be(false)
    end
    it 'returns true if the name of the client_type is Agency or Advertiser' do
      client_type.name = 'Advertiser'
      expect(client_type.locked).to be(true)
    end

    it 'returns true if the name of the client_type is Agency or Advertiser' do
      client_type.name = 'Agency'
      expect(client_type.locked).to be(true)
    end
  end

  context 'used' do
    it 'returns false if no clients use this type' do
      expect(client_type.used).to eq(false)
    end

    it 'returns true if any clients use this type' do
      client = create :client, client_type: client_type
      expect(client_type.used).to eq(true)
    end
  end
end
