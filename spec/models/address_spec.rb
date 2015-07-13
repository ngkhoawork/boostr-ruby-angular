require 'rails_helper'

RSpec.describe Address, type: :model do

  context 'phone number' do
    it 'is stripped and stored as an integer' do
      address = Address.create(phone: '(208) 867-5309')

      expect(address.phone).to eq('2088675309')
    end
  end

  context 'mobile number' do
    it 'is stripped and stored as an integer' do
      address = Address.create(mobile: '(208) 867-5309')

      expect(address.mobile).to eq('2088675309')
    end
  end
end
