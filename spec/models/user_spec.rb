require 'rails_helper'

RSpec.describe User, 'association' do
  it { should have_many(:client_members) }
  it { should have_many(:clients).through(:client_members) }
end

RSpec.describe User, type: :model do
  let(:user) { create :user }

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
    let(:user) { create :user, first_name: 'Bobby', last_name: 'Jones' }

    it 'returns the first initial and last name if they are both present' do
      expect(user.name).to eq('B. Jones')
    end
  end
end
