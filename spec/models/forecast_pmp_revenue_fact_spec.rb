require 'rails_helper'

RSpec.describe ForecastPmpRevenueFact, 'scopes' do
  describe 'by_time_dimension_id' do
    before do
      create_list :forecast_pmp_revenue_fact, 2, forecast_time_dimension: forecast_time_dimension
    end

    it 'returns forecast pmp revenue facts by time dimension id' do
      expect(ForecastPmpRevenueFact.by_time_dimension_id(forecast_time_dimension.id).count).to eq(2)
    end
  end

  describe 'by_user_dimension_ids' do
    before do
      create_list :forecast_pmp_revenue_fact, 2, user_dimension: user_dimension
    end

    it 'returns forecast pmp revenue facts by user dimension ids' do
      expect(ForecastPmpRevenueFact.by_user_dimension_ids([user_dimension.id]).count).to eq(2)
    end
  end

  describe 'by_product_dimension_ids' do
    before do
      create_list :forecast_pmp_revenue_fact, 2, product_dimension: product_dimension
    end

    it 'returns forecast pmp revenue facts by product dimension ids' do
      expect(ForecastPmpRevenueFact.by_product_dimension_ids([product_dimension.id]).count).to eq(2)
    end
  end

  private

  def forecast_time_dimension
    @_forecast_time_dimension ||= create :forecast_time_dimension
  end

  def user_dimension
    @_user_dimension ||= create :user_dimension
  end

  def product_dimension
    @_product_dimension ||= create :product_dimension
  end
end

RSpec.describe ForecastPmpRevenueFact, 'associations' do
  it { should belong_to(:forecast_time_dimension) }
  it { should belong_to(:user_dimension) }
  it { should belong_to(:product_dimension) }
end