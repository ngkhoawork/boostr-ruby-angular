require 'rails_helper'

RSpec.describe User, 'association' do
  it { should have_many(:client_members) }
  it { should have_many(:clients).through(:client_members) }
end

RSpec.describe User, type: :model do
  let(:company) { Company.first }
  let(:user) { create :user }

  context 'scopes' do
    let(:deal) { create :deal }
    let!(:deal_member) { create :deal_member, user: user, deal: deal }
    let(:team) { create :parent_team, leader: user }

    it 'has many deals that only belong to the company' do
      expect(user.reload.deals).to include(deal)
    end

    it 'has many teams that only belong to the company' do
      expect(user.reload.teams).to include(team)
    end
  end

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
      expect(user.name).to eq('Bobby Jones')
    end
  end
end
