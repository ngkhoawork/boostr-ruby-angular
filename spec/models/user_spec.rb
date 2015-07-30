require 'rails_helper'

RSpec.describe User, 'association' do
  it { should have_many(:client_members) }
  it { should have_many(:clients).through(:client_members) }
end

RSpec.describe User, type: :model do
  let(:user) { create :user, first_name: nil, last_name: nil }

  context 'roles' do
    it 'default to user' do
      expect(user.roles).to eq(['user'])
    end

    it 'can be set' do
      user.roles = ['superadmin']
      user.save
      expect(user.roles).to eq(['superadmin'])
    end

    it 'can be verified' do
      expect(user.is?(:user)).to be(true)
      expect(user.is?(:admin)).to be(false)
    end
  end

  context 'name' do
    it 'returns an empty string if name is nil' do
      expect(user.name).to eq('')
    end

    it 'returns the first initial if the first name is present' do
      user.update_attributes(first_name: 'Bobby')
      expect(user.name).to eq('B.')
    end

    it 'returns the last name if the last name is present' do
      user.update_attributes(last_name: 'Jones')
      expect(user.name).to eq('Jones')
    end

    it 'returns the first initial and last name if they are both present' do
      user.update_attributes(first_name: 'Bobby', last_name: 'Jones')
      expect(user.name).to eq('B. Jones')
    end
  end
end
