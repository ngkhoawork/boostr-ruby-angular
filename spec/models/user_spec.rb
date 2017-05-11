require 'rails_helper'

RSpec.describe User, 'association' do
  it { should have_many(:client_members) }
  it { should have_many(:clients).through(:client_members) }
end

RSpec.describe User, type: :model do
  let(:company) { Company.first }
  let(:user) { create :user }

  context 'before_update' do
    it 'promotes user to an admin if user type is changed to ADMIN' do
      expect(user.is?('admin')).to eq false
      user.update(user_type: ADMIN)
      expect(user.reload.is?('admin')).to eq true
    end
  end

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

    it 'finds user by email case insensitively' do
      expect(User.by_email(user.email.upcase)).to eq [user]
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

  describe '#add_role' do
    it 'adds a role' do
      expect(user.is?('admin')).to eq false
      user.add_role('admin')
      expect(user.is?('admin')).to eq true
    end

    it 'does not add an existing role' do
      user.update(roles_mask: 3)
      expect(user.is?('admin')).to eq true
      user.add_role('admin')
      expect(user.roles_mask).to eq 3
    end
  end

  describe '#remove_role' do
    it 'removes a role' do
      user.update(roles_mask: 3)
      expect(user.is?('admin')).to eq true
      user.remove_role('admin')
      expect(user.is?('admin')).to eq false
    end

    it 'does not remove a non-existing role' do
      expect(user.is?('admin')).to eq false
      user.remove_role('admin')
      expect(user.roles_mask).to eq 1
    end
  end

  describe '#is_active?' do
    it 'is true for active users' do
      expect(user.is_active?).to be(true)
    end

    it 'is false for inactive users' do
      user.is_active = false
      expect(user.is_active?).to be(false)
    end
  end

  describe '#inactive_message' do
    it 'returns :user_is_not_active if user is inactive' do
      user.is_active = false
      expect(user.inactive_message).to be(:inactive)
    end
  end

  describe '#active_for_authentication?' do
    it 'is true for active users' do
      expect(user.active_for_authentication?).to be(true)
    end

    it 'is false for inactive users' do
      user.is_active = false
      expect(user.active_for_authentication?).to be(false)
    end
  end
end
