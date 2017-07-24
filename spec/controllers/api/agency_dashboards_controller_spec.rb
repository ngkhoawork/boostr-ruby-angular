require 'rails_helper'

describe Api::AgencyDashboardsController, type: :controller do
  let(:response_body) { JSON.parse(response.body, symbolize_names: true) }

  before do
    sign_in user
  end


  describe 'GET #spend_by_product' do
    let(:account) { create(:account) }
    let!(:pipeline_fact_0) do
      create(:account_product_pipeline_fact,
             time_dimension: future_month_time_dimension,
             product_dimension: product_dimension,
             account_dimension: account_dimension,
             company: company,
             weighted_amount: 10_000,
             unweighted_amount: 20_000)
    end

    let!(:pipeline_fact_1) do
      create(:account_product_pipeline_fact,
             time_dimension: future_month_time_dimension,
             product_dimension: product_dimension,
             account_dimension: account_dimension,
             company: company,
             weighted_amount: 10_000,
             unweighted_amount: 20_000)
    end

    let!(:revenue_fact) do
      create(:account_product_revenue_fact, time_dimension: current_month_time_dimension,
             product_dimension: product_dimension,
             account_dimension: account_dimension,
             company: company,
             revenue_amount: 10_000)
    end

    it 'returns revenues and summed pipelines for products by account and time dimensions' do
      get :spend_by_product,
          holding_company_id: holding_company.id,
          start_date: current_month_time_dimension.start_date,
          end_date: future_month_time_dimension.end_date,
          format: :json
      expect(response_body[1][:name]).to eq(product_dimension.name)
      expect(response_body[1][:sum]).to eq((pipeline_fact_0.weighted_amount + pipeline_fact_1.weighted_amount).to_s)
      expect(response_body[0][:sum]).to eq(revenue_fact.revenue_amount)
    end
  end

  describe 'GET #spend_by_advertisers' do
    it 'return spend values by each agency related advertiser' do

    end
  end

  private

  def future_month_time_dimension
    @future_month_time_dimension || create(:time_dimension,
                                           start_date: Date.today.beginning_of_month + 1.month,
                                           end_date: Date.today.end_of_month + 1.month,
                                           days_length: (Date.today.end_of_month - Date.today.beginning_of_month).to_i)
  end

  def current_month_time_dimension
    @current_month_time_dimension || create(:time_dimension,
                                            start_date: Date.today.beginning_of_month,
                                            end_date: Date.today.end_of_month,
                                            days_length: (Date.today.end_of_month - Date.today.beginning_of_month).to_i)
  end

  def product
    @product ||= create(:product)
  end

  def account
    @account ||= create(:client)
  end

  def product_dimension
    @product_dimension ||= create(:product_dimension,
                                  id: product.id,
                                  name: product.name,
                                  revenue_type: product.revenue_type)
  end

  def user
    @user ||= create(:user, company: company)
  end

  def account_dimension
    @account_dimension ||= create(:account_dimension, id: account.id, holding_company: holding_company)
  end

  def holding_company
    @holding_company ||= create(:holding_company)
  end

  def company
    @company ||= create(:company)
  end
end