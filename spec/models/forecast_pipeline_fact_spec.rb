require 'rails_helper'

RSpec.describe ForecastPipelineFact, type: :model do
  context 'after create deal' do
    before(:each) do
      user(win_rate: 0.5, average_deal_size: 300, confirmed_at: Time.now)
      user2(win_rate: 0.2, average_deal_size: 200, confirmed_at: Time.now)
      time_period(start_date: '2015-04-01', end_date: '2015-06-30', period_type: 'year')
      stage(probability: 50, open: true)
      stage2(probability: 90, open: true)
      won_stage(probability: 100, open: false)
      lost_stage(probability: 0, open: false)
      deal(stage: stage, start_date: '2015-04-01', end_date: '2015-06-30', curr_cd: 'USD')
      deal_product(deal: deal, budget: 10000, budget_loc: 10000, product: product)
      deal_product2(deal: deal, budget: 20000, budget_loc: 20000, product: product2)
      deal_member(deal: deal, user: user, share: 60)
      deal_member2(deal: deal, user: user2, share: 40)
    end

    it 'generate correct split amount' do
      expect(forecast_pipeline_fact.amount.to_f).to eq(6000.0)
      expect(forecast_pipeline_fact2.amount.to_f).to eq(4000.0)
    end

    it 'deal product budget change update fact' do
      deal.reload
      deal_product.update(budget: '20000.00')
      expect(forecast_pipeline_fact.reload.amount.to_f).to eq(12000.0)
      expect(forecast_pipeline_fact2.reload.amount.to_f).to eq(8000.0)
    end

    it 'deal start & end date change update fact' do
      deal.reload
      deal.update(start_date: '2015-03-15')
      expect(forecast_pipeline_fact.reload.amount.to_f).to eq(5055.6)
      expect(forecast_pipeline_fact2.reload.amount.to_f).to eq(3370.4)
    end

    it 'deal product deletion update fact' do
      deal.reload
      deal_product.destroy
      expect(forecast_pipeline_fact).to be_nil
      expect(forecast_pipeline_fact2).to be_nil
    end

    it 'deal deletion update fact' do
      deal.reload
      deal.destroy
      expect(forecast_pipeline_fact).to be_nil
      expect(forecast_pipeline_fact2).to be_nil
    end

    it 'deal member deletion update fact' do
      deal.reload
      deal_member.destroy
      expect(forecast_pipeline_fact).to be_nil
      expect(forecast_pipeline_fact2.amount.to_f).to eq(4000.0)
    end

    it 'deal member share change update fact' do
      deal.reload
      user.reload
      user2.reload
      deal_member.update(share: 10)
      deal_member2.update(share: 90)
      expect(forecast_pipeline_fact.amount.to_f).to eq(1000.0)
      expect(forecast_pipeline_fact2.amount.to_f).to eq(9000.0)
    end

    it 'deal stage change update fact' do
      deal.reload
      deal.update(stage_id: stage2.id)
      new_forecast_pipeline_fact = ForecastPipelineFact.find_by(user_dimension_id: user.id, product_dimension_id: product.id, stage_dimension_id: stage2.id, forecast_time_dimension_id: time_period.id)
      new_forecast_pipeline_fact2 = ForecastPipelineFact.find_by(user_dimension_id: user2.id, product_dimension_id: product.id, stage_dimension_id: stage2.id, forecast_time_dimension_id: time_period.id)

      expect(new_forecast_pipeline_fact.amount.to_f).to eq(6000)
      expect(new_forecast_pipeline_fact2.amount.to_f).to eq(4000)
      expect(forecast_pipeline_fact).to be_nil
      expect(forecast_pipeline_fact2).to be_nil
    end

    it 'won deal update fact' do
      deal.reload
      deal.update(stage_id: won_stage.id)
      new_forecast_pipeline_fact = ForecastPipelineFact.find_by(user_dimension_id: user.id, product_dimension_id: product.id, stage_dimension_id: won_stage.id, forecast_time_dimension_id: time_period.id)
      new_forecast_pipeline_fact2 = ForecastPipelineFact.find_by(user_dimension_id: user2.id, product_dimension_id: product.id, stage_dimension_id: won_stage.id, forecast_time_dimension_id: time_period.id)

      expect(new_forecast_pipeline_fact).to be_nil
      expect(new_forecast_pipeline_fact2).to be_nil
      expect(forecast_pipeline_fact).to be_nil
      expect(forecast_pipeline_fact2).to be_nil
    end

    it 'lost deal update fact' do
      deal.reload
      deal.update(stage_id: lost_stage.id)
      new_forecast_pipeline_fact = ForecastPipelineFact.find_by(user_dimension_id: user.id, product_dimension_id: product.id, stage_dimension_id: lost_stage.id, forecast_time_dimension_id: time_period.id)
      new_forecast_pipeline_fact2 = ForecastPipelineFact.find_by(user_dimension_id: user2.id, product_dimension_id: product.id, stage_dimension_id: lost_stage.id, forecast_time_dimension_id: time_period.id)

      expect(new_forecast_pipeline_fact).to be_nil
      expect(new_forecast_pipeline_fact2).to be_nil
      expect(forecast_pipeline_fact).to be_nil
      expect(forecast_pipeline_fact2).to be_nil
    end
  end

  def company()
    @_company ||= create :company
  end

  def deal(opts={})
    opts[:company_id] = company.id
    @_deal ||= create :deal, opts
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

  def user(opts={})
    opts[:company_id] = company.id
    @_user ||= create :user, opts
  end

  def user2(opts={})
    opts[:company_id] = company.id
    @_user2 ||= create :user, opts
  end

  def product(opts={})
    opts[:company_id] = company.id
    @_product ||= create :product, opts
  end

  def product2(opts={})
    opts[:company_id] = company.id
    @_product2 ||= create :product, opts
  end

  def time_period(opts={})
    opts[:company_id] = company.id
    @_time_period ||= create :time_period, opts
  end

  def stage(opts={})
    opts[:company_id] = company.id
    @_stage ||= create :stage, opts
  end

  def stage2(opts={})
    opts[:company_id] = company.id
    @_stage2 ||= create :stage, opts
  end

  def won_stage(opts={})
    opts[:company_id] = company.id
    @_won_stage ||= create :stage, opts
  end

  def lost_stage(opts={})
    opts[:company_id] = company.id
    @_lost_stage ||= create :stage, opts
  end

  def forecast_pipeline_fact
    @_forecast_pipeline_fact ||= ForecastPipelineFact.find_by(user_dimension_id: user.id, product_dimension_id: product.id, stage_dimension_id: stage.id, forecast_time_dimension_id: time_period.id)
  end

  def forecast_pipeline_fact2
    @_forecast_pipeline_fact2 ||= ForecastPipelineFact.find_by(user_dimension_id: user2.id, product_dimension_id: product.id, stage_dimension_id: stage.id, forecast_time_dimension_id: time_period.id)
  end
end
