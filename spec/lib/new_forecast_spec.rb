require 'rails_helper'

RSpec.describe NewForecast do
  context 'as_json' do
    before do
      time_period
      deal(stage: stage, start_date: '2015-01-01', end_date: '2015-12-31', curr_cd: 'USD')
      deal_product(deal: deal, product: product, budget: 100, budget_loc: 100)
      deal_member(deal: deal, user: leader, share: 50)
      deal_member2(deal: deal, user: user, share: 50)
      deal.reload
    end
    it 'returns all root teams and nested teams and members' do
      expect(forecast.teams.length).to eq(1)
      expect(forecast.teams[0].teams.length).to eq(1)
      expect(forecast.weighted_pipeline).to eq(50)
    end
  end

  def company
    @_company ||= create :company
  end

  def leader
    @_leader ||= create :user, company: company, win_rate: 0.5, average_deal_size: 100
  end

  def parent
    @_parent ||= create :parent_team, company: company
  end

  def stage
    @_stage ||= create :stage, company: company, probability: 50, open: true
  end

  def product
    @_product ||= create :product, company: company
  end

  def child
    @_child ||= create :child_team, company: company, parent: parent, leader: leader
  end

  def user
    @_user ||= create :user, company: company, team: child, win_rate: 0.5, average_deal_size: 100
  end

  def time_period
    @_time_period ||= create :time_period, company: company, start_date: '2015-01-01', end_date: '2015-12-31', period_type: 'year'
  end

  def deal(opts={})
    opts[:company_id] = company.id
    @_deal ||= create :deal, opts
  end

  def deal_product(opts={})
    @_deal_product ||= create :deal_product, opts
  end

  def deal_member(opts={})
    @_deal_member ||= create :deal_member, opts
  end

  def deal_member2(opts={})
    @_deal_member2 ||= create :deal_member, opts
  end

  def forecast
    @_forecast ||= NewForecast.new(company, company.teams.roots(true), time_period)
  end
end
