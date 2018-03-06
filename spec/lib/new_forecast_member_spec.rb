require 'rails_helper'

RSpec.describe NewForecastMember do
  context 'as_json' do
    before do
      time_period
      quota
    end

    it 'returns the revenue for a member that has no revenue' do
      expect(forecast.revenue).to eq(0)
    end

    context 'with revenue' do
      it 'sums the revenue' do
        io(start_date: '2015-04-01', end_date: '2015-06-30')
        content_fee(io: io, product: products[0], budget: 10000, budget_loc: 10000)
        content_fee2(io: io, product: products[1], budget: 5000, budget_loc: 5000)
        io_member(io: io, user: user, share: 100, from_date: '2015-04-01', to_date: '2015-06-30')
        expect(forecast.revenue).to eq(15000)
      end

      it 'sums the split revenue' do
        io(start_date: '2015-04-01', end_date: '2015-06-30')
        content_fee(io: io, product: products[0], budget: 10000, budget_loc: 10000)
        content_fee2(io: io, product: products[1], budget: 5000, budget_loc: 5000)
        io_member(io: io, user: user, share: 60, from_date: '2015-04-01', to_date: '2015-06-30')
        expect(forecast.revenue).to eq(9000)
      end

      it 'does not sum revenue outside of the time period' do
        io(start_date: '2016-04-01', end_date: '2016-06-30')
        content_fee(io: io, product: products[0], budget: 10000, budget_loc: 10000)
        content_fee2(io: io, product: products[1], budget: 5000, budget_loc: 5000)
        io_member(io: io, user: user, share: 60, from_date: '2015-04-01', to_date: '2015-06-30')
        expect(forecast.revenue).to eq(0)
      end
    end

    context 'weighted_pipeline' do
      before do
        deal(stage: stage, start_date: '2015-01-01', end_date: '2015-01-31', curr_cd: 'USD')
        deal_product(deal: deal, budget: 10000, budget_loc: 10000, product: products[0])
        deal_product2(deal: deal, budget: 20000, budget_loc: 20000, product: products[1])
        deal_member(deal: deal, user: user, share: 100)
        deal.reload
      end
      it 'sums the weighted_pipeline' do
        expect(forecast.weighted_pipeline).to eq(30000)
      end

      it 'sums the split weighted_pipeline' do
        user.reload
        deal_member.update(share: 50)
        expect(forecast.weighted_pipeline).to eq(15000)
      end

      it 'does not include closed deals' do
        deal.update(open: false)
        expect(forecast.weighted_pipeline).to eq(0)
      end

      it 'does not sum weighted_pipeline outside of the time period' do
        deal.update(start_date: '2014-12-15')
        expect(forecast.weighted_pipeline).to eq(19375)
      end

      it 'applies the probability to the total' do
        stage.update(probability: 50)
        expect(forecast.weighted_pipeline).to eq(15000)
      end
    end

    context 'weighted_pipeline_by_stage' do
      before do
        deal(stage: stage, start_date: '2015-01-01', end_date: '2015-01-31', curr_cd: 'USD')
        deal_product(deal: deal, budget: 10000, budget_loc: 10000, product: products[0])
        deal_member(deal: deal, user: user, share: 100)

        user.reload
        deal2(stage: stage2, start_date: '2015-01-01', end_date: '2015-01-31', curr_cd: 'USD')
        deal_product2(deal: deal2, budget: 20000, budget_loc: 20000, product: products[1])
        deal_member2(deal: deal2, user: user, share: 100)
        deal.reload
      end

      it 'lists the weighted pipeline by stage' do
        stages = {}
        stages[stage.id] = 10000.0
        stages[stage2.id] = 18000.0

        expect(forecast.weighted_pipeline_by_stage).to eq(stages)
      end

      it 'lists the stages in the weighted pipeline by stage data' do
        expect(forecast.stages).to eq([stage, stage2])
      end
    end

    context 'quota' do
      let!(:quota) { create :quota, user: user, value: 10000, time_period: time_period }

      it 'returns the quota value' do
        deal.reload
        expect(forecast.quota).to eq(10000)
      end
    end

    context 'gap_to_quota' do
      before do
        io(start_date: '2015-04-01', end_date: '2015-06-30')
        content_fee(io: io, product: products[0], budget: 500, budget_loc: 500)
        io_member(io: io, user: user, share: 100, from_date: '2015-04-01', to_date: '2015-06-30')
        io.reload

        deal(stage: stage, start_date: '2015-01-01', end_date: '2015-01-31', curr_cd: 'USD')
        deal_product(deal: deal, budget: 10000, budget_loc: 10000, product: products[0])
        deal_member(deal: deal, user: user, share: 100)
        deal.reload
      end

      it 'returns the gap to quota value' do
        expect(forecast.revenue).to eq(500)
        expect(forecast.weighted_pipeline).to eq(10000)
        expect(forecast.gap_to_quota).to eq(2000)
      end
    end

  end

  def company
    @_company ||= Company.first
  end

  def user
    @_user ||= create :user, win_rate: 0.5, average_deal_size: 300
  end

  def time_period
    @_time_period ||= create :time_period, start_date: '2015-01-01', end_date: '2015-12-31', period_type: 'year'
  end

  def products
    @_products ||= create_list :product, 2
  end

  def quota
    @_quota ||= create :quota, user: user, value: 12500, time_period: time_period
  end

  def stage
    @_stage ||= create :stage, probability: 100, open: true
  end

  def stage2
    @_stage2 ||= create :stage, probability: 90, open: true
  end

  def deal(opts={})
    opts[:company_id] = company.id
    @_deal ||= create :deal, opts
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

  def snapshot(opts={})
    opts[:company_id] = company.id
    @_snapshot ||= create :snapshot, opts
  end

  def snapshot2(opts={})
    opts[:company_id] = company.id
    @_snapshot2 ||= create :snapshot, opts
  end

  def forecast
    @_forecast ||= NewForecastMember.new(user, time_period)
  end
end
