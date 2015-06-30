require 'rails_helper'

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
end