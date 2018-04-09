require 'rails_helper'

describe DealMember, type: :model do
  context 'validation' do
    it { should validate_presence_of(:share) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:deal_id) }
  end

  context 'association' do
    it { should belong_to(:deal) }
    it { should belong_to(:user) }
  end

  context 'scopes' do
    context 'by_team' do
      before do
        deal_product
        parent_deal_member
        child_deal_member
      end

      it 'returns all members of team' do
        expect(DealMember.by_team(parent_team.id).count).to eq(2)
      end
    end
  end

  def leader
    @_leader ||= create :user, company: company
  end

  def company
    @_company ||= create :company
  end

  def child_team
    @_child_team ||= create :child_team, parent: parent_team, company: company
  end

  def parent_team
    @_parent_team ||= create :parent_team, leader: leader, company: company
  end

  def parent_team_member
    @_parent_team_member ||= create :user, company: company, team: parent_team
  end

  def child_team_member
    @_child_team_member ||= create :user, company: company, team: child_team
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def product
    @_product ||= create :product, company: company
  end

  def stage
    @_stage ||= create :stage, company: company, probability: 50, open: true
  end

  def deal_product
    @_deal_product ||= create :deal_product, product: product
  end

  def parent_deal_member
    @_parent_deal_member ||= create :deal_member, deal: deal, user: parent_team_member
  end

  def child_deal_member
    @_child_deal_member ||= create :deal_member, deal: deal, user: child_team_member
  end
end
