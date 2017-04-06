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

  describe '#crevenues' do
    it 'counts team revenue for time period' do
      time_period(start_date: Date.new(2017, 1, 1), end_date: Date.new(2017, 3, 31))
      io(start_date: time_period.start_date, end_date: time_period.end_date)
      content_fee(io: io, budget: 200_000)
      io_member(io: io, user: another_user, share: 25, from_date: time_period.start_date, to_date: time_period.end_date)
      io_member(io: io, user: user, share: 75, from_date: time_period.start_date, to_date: time_period.end_date)

      crevenue = parent.crevenues(time_period.start_date, time_period.end_date).first

      expect(crevenue[:sum_period_budget]).to be 200_000.0
      expect(crevenue[:split_period_budget]).to be 150_000.0
    end

    #TODO NEED MORE TESTS HERE
  end

  def user
    @_user ||= create :user, company: company, team: parent
  end

  def another_user#(opts={})
    # opts.merge!(company: company)
    @_another_user ||= create :user, company: company
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
end
