require 'rails_helper'

RSpec.describe User, 'association' do
  it { should have_many(:client_members) }
  it { should have_many(:clients).through(:client_members) }
end

RSpec.describe User, type: :model do
  let(:user) { create :user }

  context 'scopes' do
    let(:company) { create :company }
    let(:deal) { create :deal, company: company }
    let!(:deal_member) { create :deal_member, user: user, deal: deal }
    let(:team) { create :parent_team, company: company, leader: user }

    it 'has many deals that only belong to the company' do
      user.update_attributes(company_id: company.id)
      expect(user.reload.deals).to include(deal)
    end

    it 'has no deals because they do not belong to the company' do
      expect(user.reload.deals).to_not include(deal)
    end

    it 'has many teams that only belong to the company' do
      user.update_attributes(company_id: company.id)
      expect(user.reload.teams).to include(team)
    end

    it 'has no teams because they do not belong to the company' do
      expect(user.reload.teams).to_not include(team)
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
      expect(user.name).to eq('B. Jones')
    end
  end

  context 'full_name' do
    let(:user) { create :user, first_name: 'Bobby', last_name: 'Jones' }

    it 'returns the first initial and last name if they are both present' do
      expect(user.full_name).to eq('Bobby Jones')
    end
  end
end
