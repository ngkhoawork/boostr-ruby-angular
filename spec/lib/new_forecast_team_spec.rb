require 'rails_helper'

RSpec.describe NewForecastTeam do
  context 'as_json' do
    before do
      time_period
    end

    context 'with a leader' do
      before do
        team(leader: leader)
        member(team: team, win_rate: 0.5, average_deal_size: 100)
        leader_quota(user: leader, value: 5000, time_period: time_period)
        member_quota(user: member, value: 2000, time_period: time_period)
        stage(probability: 50, open: true)
        deal(stage: stage, start_date: '2015-01-01', end_date: '2015-12-31')
        deal_product(deal: deal, budget: 100, budget_loc: 100)
        deal_member(deal: deal, user: leader, share: 50)
        deal_member2(deal: deal, user: member, share: 50)
        deal.reload
      end
      

      it 'returns the revenue for a member that has no revenue' do
        expect(forecast.revenue).to eq(0)
      end

      context 'with revenue' do
        it 'sums the split revenue' do
          another_user(team: team)
          io(start_date: '2015-04-01', end_date: '2015-06-30')
          content_fee(io: io, product: products[0], budget: 10000, budget_loc: 10000)
          io_member(io: io, user: leader, share: 50, from_date: '2015-04-01', to_date: '2015-06-30')
          io_member2(io: io, user: another_user, share: 50, from_date: '2015-04-01', to_date: '2015-06-30')
          io.reload

          expect(forecast.revenue).to eq(10000)
        end
      end

      context 'weighted_pipeline' do
        it 'sums the weighted_pipeline' do
          expect(forecast.weighted_pipeline).to eq(50)
        end
      end

      context 'quota' do
        it 'returns the quota value of the team leader' do
          expect(forecast.quota).to eq(5000)
        end
      end

      context 'gap_to_quota' do
        it 'returns the gap to quota value' do
          expect(forecast.revenue).to eq(0)
          expect(forecast.weighted_pipeline).to eq(50)
          expect(forecast.gap_to_quota).to eq(4950)
        end
      end

      context 'new_deals_needed' do
        it 'returns the number of new deals needed to meet the quota' do
          expect(forecast.gap_to_quota).to eq(4950)
          expect(forecast.new_deals_needed).to eq('N/A')
        end
      end
    end

    context 'parents' do
      before do
        parent_parent_team()
        parent_team(parent: parent_parent_team)
        team(parent: parent_team)
      end

      it 'has parent teams' do
        expect(forecast.parents).to eq([
          { id: parent_parent_team.id, name: parent_parent_team.name },
          { id: parent_team.id, name: parent_team.name }
        ])
      end
    end

    context 'without a leader' do
      before do
        team
        member(team: team)
        member_quota(user: member, value: 2000, time_period: time_period)
      end

      context 'with revenue' do
        it 'sums the split revenue' do
          another_user(team: team)
          io(start_date: '2015-04-01', end_date: '2015-06-30')
          content_fee(io: io, product: products[0], budget: 10000, budget_loc: 10000)
          io_member(io: io, user: leader, share: 50, from_date: '2015-04-01', to_date: '2015-06-30')
          io_member2(io: io, user: another_user, share: 50, from_date: '2015-04-01', to_date: '2015-06-30')
          io.reload
          expect(forecast.revenue).to eq(5000)
        end
      end

      context 'weighted_pipeline' do
        before do
          stage(probability: 50, open: true)
          deal(stage: stage, start_date: '2015-01-01', end_date: '2015-12-31')
          deal_product(deal: deal, budget: 10000, budget_loc: 10000)
          deal_member(deal: deal, user: member, share: 50)
          deal.reload
        end

        it 'sums the weighted_pipeline' do
          expect(forecast.weighted_pipeline).to eq(2500)
        end
      end

      context 'quota' do
        it 'returns the quota value of the team leader' do
          expect(forecast.quota).to eq(0)
        end
      end
    end
  end
    
  def company
    @_company ||= Company.first
  end

  def leader
    @_leader ||= create :user, win_rate: 0.5, average_deal_size: 100
  end

  def time_period
    @_time_period ||= create :time_period, start_date: '2015-01-01', end_date: '2015-12-31', period_type: 'year'
  end

  def products
    @_products ||= create_list :product, 2
  end

  def deal(opts={})
    opts[:company_id] = company.id
    @_deal ||= create :deal, opts
  end

  def team(opts={})
    opts[:company_id] = company.id
    @_team ||= create :parent_team, opts
  end

  def parent_team(opts={})
    opts[:company_id] = company.id
    @_parent_team ||= create :parent_team, opts
  end

  def parent_parent_team(opts={})
    opts[:company_id] = company.id
    @_parent_parent_team ||= create :parent_team, opts
  end

  def member(opts={})
    opts[:company_id] = company.id
    @_member ||= create :user, opts
  end

  def another_user(opts={})
    opts[:company_id] = company.id
    @_another_user ||= create :user, opts
  end

  def leader_quota(opts={})
    opts[:company_id] = company.id
    @_leader_quota ||= create :quota, opts
  end

  def member_quota(opts={})
    opts[:company_id] = company.id
    @_member_quota ||= create :quota, opts
  end

  def stage(opts={})
    opts[:company_id] = company.id
    @_stage ||= create :stage, opts
  end

  def deal2(opts={})
    opts[:company_id] = company.id
    @_deal2 ||= create :deal, opts
  end

  def deal_product(opts={})
    @_deal_product ||= create :deal_product, opts
  end

  def deal_product2(opts={})
    @_deal_product2 ||= create :deal_product, opts
  end

  def deal_member(opts={})
    @_deal_member ||= create :deal_member, opts
  end

  def deal_member2(opts={})
    @_deal_member2 ||= create :deal_member, opts
  end

  def io(opts={})
    opts[:company_id] = company.id
    @_io ||= create :io, opts
  end

  def io2(opts={})
    opts[:company_id] = company.id
    @_io2 ||= create :io, opts
  end

  def io_member(opts={})
    @_io_member ||= create :io_member, opts
  end

  def io_member2(opts={})
    @_io_member2 ||= create :io_member, opts
  end

  def content_fee(opts={})
    @_content_fee ||= create :content_fee, opts
  end

  def content_fee2(opts={})
    @_content_fee2 ||= create :content_fee, opts
  end

  def forecast
    @_forecast ||= NewForecastTeam.new(team, time_period)
  end
end
