require 'rails_helper'

RSpec.describe ForecastRevenueFact, type: :model do
  context 'io with content fee' do
    before(:each) do
      user(win_rate: 0.5, average_deal_size: 300, confirmed_at: Time.now)
      user2(win_rate: 0.2, average_deal_size: 200, confirmed_at: Time.now)
      time_period(start_date: '2015-04-01', end_date: '2015-06-30', period_type: 'quarter')
      product
      io(start_date: '2015-04-01', end_date: '2015-06-30')
      content_fee(io: io, product: product, budget: 10000, budget_loc: 10000)
      io_member(io: io, user: user, share: 60, from_date: '2015-04-01', to_date: '2015-06-30')
      io_member2(io: io, user: user2, share: 40, from_date: '2015-04-01', to_date: '2015-06-30')
      io.reload
      user.reload
      user2.reload
    end
    it 'generate correct split amount' do
      expect(io.budget).to eql 10000.0
      expect(io_member.share).to eql 60
      expect(forecast_revenue_fact.amount).to eql(6000)
      expect(forecast_revenue_fact2.reload.amount).to eq(4000)
    end

    it 'content fee budget change update fact' do
      content_fee.update(budget: '20000.00', budget_loc: '20000.00')
      expect(forecast_revenue_fact.reload.amount).to eq(12000)
      expect(forecast_revenue_fact2.reload.amount).to eq(8000)
    end

    it 'io start & end date change update fact' do
      io.update(start_date: '2015-03-15')
      expect(forecast_revenue_fact.reload.amount).to eq(5055.6)
      expect(forecast_revenue_fact2.reload.amount).to eq(3370.4)
    end

    it 'content fee deletion update fact' do
      content_fee.destroy
      expect(forecast_revenue_fact).to be_nil
      expect(forecast_revenue_fact2).to be_nil
    end

    it 'io deletion update fact' do
      io.destroy
      expect(forecast_revenue_fact).to be_nil
      expect(forecast_revenue_fact2).to be_nil
    end

    it 'io member deletion update fact' do
      io_member.destroy
      expect(forecast_revenue_fact).to be_nil
      expect(forecast_revenue_fact2.amount).to eq(4000.0)
    end

    it 'io member share change update fact' do
      io_member.update(share: 10)
      io_member2.update(share: 90)
      expect(forecast_revenue_fact.amount).to eq(1000)
      expect(forecast_revenue_fact2.amount).to eq(9000)
    end
  end

  def deal(opts={})
    opts[:company_id] = company.id
    @_deal ||= create :deal, opts
  end

  def discuss_stage
    @_discuss_stage ||= create :discuss_stage, company_id: company.id
  end

  def closed_stage
    @_closed_stage ||= create :closed_won_stage, company_id: company.id
  end

  def io(opts={})
    opts[:company_id] = company.id
    @_io ||= create :io, opts
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

  def content_fee_product_budget()
    @_content_fee_product_budget ||= content_fee.content_fee_product_budgets.first
  end

  def temp_io(opts={})
    opts[:company_id] = company.id
    @_temp_io ||= create :temp_io, opts
  end

  def company(opts={})
    @_company ||= create :company
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

  def time_period(opts={})
    opts[:company_id] = company.id
    @_time_period ||= create :time_period, opts
  end

  def forecast_revenue_fact
    @_forecast_revenue_fact ||= ForecastRevenueFact.find_by(user_dimension_id: user.id, product_dimension_id: product.id, forecast_time_dimension_id: time_period.id)
  end

  def forecast_revenue_fact2
    @_forecast_revenue_fact2 ||= ForecastRevenueFact.find_by(user_dimension_id: user2.id, product_dimension_id: product.id, forecast_time_dimension_id: time_period.id)
  end
end
