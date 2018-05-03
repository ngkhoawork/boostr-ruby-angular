require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:parent) { create :parent_team, company: company }
  let!(:child) { create :child_team, parent: parent, company: company }

  context 'scopes' do
    describe '#roots' do

      it 'returns all parentless teams' do
        expect(Team.all.length).to eq(2)
        expect(Team.roots(true).length).to eq(1)
        expect(Team.roots(false).length).to eq(2)
      end

      it 'has many members that only belong to the company' do
        expect(parent.reload.members).to include(user)
      end
    end
  end

  context '#all_deals_for_time_period' do
    let(:time_period) { create :time_period, company: company }
    let(:parent_member) { create :user, team: parent, company: company }
    let(:child_member) { create :user, team: child, company: company }
    let(:parent_deal) { create :deal, start_date: time_period.start_date, end_date: time_period.end_date, company: company }
    let(:child_deal) { create :deal, start_date: time_period.start_date, end_date: time_period.end_date, company: company }
    let!(:parent_deal_member) { create :deal_member, deal: parent_deal, user: parent_member }
    let!(:child_deal_member) { create :deal_member, deal: child_deal, user: child_member }

    it 'returns all of the team deals as well as all of the team\'s children\'s deals' do
      all_deals = parent.all_deals_for_time_period(time_period.start_date, time_period.end_date)
      expect(all_deals.flatten.uniq.length).to eq(2)
    end
  end

  describe '#all_members_and_leaders_ids' do
    it 'selects all members and leards from root team and all nested teams' do
      root_team
      child_team(root_team)
      child_team2(child_team)

      team_members(root_team)
      team_members(child_team)
      team_members(child_team2)

      user_ids = root_team.members.ids + child_team.members.ids + child_team2.members.ids
      user_ids += [root_team, child_team, child_team2].map(&:leader_id)

      expect(root_team.reload.all_members_and_leaders_ids.pluck(:id).sort).to eq user_ids.sort
    end
  end

  def user
    @_user ||= create :user, company: company, team: parent
  end

  def another_user#(opts={})
    # opts.merge!(company: company)
    @_another_user ||= create :user, company: company
  end

  def leader_user
    @_leader_user ||= create :user, company: company
  end

  def io(opts={})
    opts.merge!(company: company)
    @_io ||= create :io, opts
  end

  def content_fee(opts={})
    @_content_fee ||= create :content_fee, opts
  end

  def io_member(opts={})
    create :io_member, opts
  end

  def time_period(opts={})
    opts.merge!(company: company)
    @_time_period ||= create :time_period, opts
  end

  def company
    @_company ||= create :company
  end

  def root_team
    @_root_team ||= create :parent_team, company: company, leader: (create :user, company: company)
  end

  def child_team(parent_team=nil)
    @_child_team ||= create :team, parent: parent_team, company: company, leader: (create :user, company: company)
  end

  def child_team2(parent_team=nil)
    @_child_team2 ||= create :team, parent: parent_team, company: company, leader: (create :user, company: company)
  end

  def team_members(team)
    create_list :user, 3, company: company, team: team
  end
end
