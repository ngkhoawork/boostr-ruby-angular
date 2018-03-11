require 'rails_helper'

describe Api::AgencyDashboardsController, type: :controller do
  let!(:company) { create :company, :fast_create_company }
  let(:response_body) { JSON.parse(response.body, symbolize_names: true) }

  before do
    sign_in user
    Io.skip_callback(:save, :after, :update_revenue_fact_callback)
    Client.skip_callback(:commit, :after, :update_account_dimension)
  end
  after do
    sign_out user
    Io.set_callback(:save, :after, :update_revenue_fact_callback)
    Client.set_callback(:commit, :after, :update_account_dimension)
  end

  describe 'GET #spend_by_product' do

    let!(:pipeline_fact) do
      create(:account_product_pipeline_fact,
             time_dimension: future_month_time_dimension,
             product_dimension: product_dimension,
             account_dimension: agency_account_dimension,
             company: company,
             weighted_amount: 10_000,
             unweighted_amount: 20_000)
    end

    let!(:revenue_fact) do
      create(:account_product_revenue_fact,
             time_dimension: current_month_time_dimension,
             product_dimension: product_dimension,
             account_dimension: agency_account_dimension,
             company: company,
             revenue_amount: 10_000)
    end

    it 'returns revenues and pipelines for products by account and time dimensions' do
      get :spend_by_product,
          holding_company_id: holding_company.id,
          start_date: current_month_time_dimension.start_date,
          end_date: future_month_time_dimension.end_date,
          format: :json

      revenue = { date: convert_date(revenue_fact.time_dimension.start_date),
                  name: product.name,
                  sum: revenue_fact.revenue_amount }
      pipeline = { date: convert_date(pipeline_fact.time_dimension.start_date),
                   name: product.name,
                   sum:  pipeline_fact.weighted_amount }

      expect(response_body).to include(revenue)
      expect(response_body).to include(pipeline)
    end
  end

  describe 'GET #spend_by_advertisers' do
    let!(:advertiser_agency_pipeline_fact) do
      create(:advertiser_agency_pipeline_fact,
             time_dimension: future_month_time_dimension,
             agency: agency_account_dimension,
             advertiser: advertiser_account_dimension,
             company: company,
             weighted_amount: 10_000,
             unweighted_amount: 20_000)
    end

    let!(:advertiser_agency_revenue_fact) do
      create(:advertiser_agency_revenue_fact,
             time_dimension: current_month_time_dimension,
             agency: agency_account_dimension,
             advertiser: advertiser_account_dimension,
             company: company,
             revenue_amount: 10_000)
    end

    let!(:client_connection){ create(:client_connection, advertiser: advertiser, agency: agency) }
    let!(:io) { create(:io, advertiser: advertiser, agency: agency) }
    let(:revenue) do
      {
        date: convert_date(advertiser_agency_revenue_fact.time_dimension.start_date),
        name: advertiser_agency_revenue_fact.advertiser.name,
        sum: advertiser_agency_revenue_fact.revenue_amount
      }
    end
    let(:pipeline) do
      {
        date: convert_date(advertiser_agency_pipeline_fact.time_dimension.start_date),
        name: advertiser_agency_pipeline_fact.advertiser.name,
        sum: advertiser_agency_pipeline_fact.weighted_amount
      }
    end

    it 'returns spend values by each agency related advertiser' do
      get :spend_by_advertisers,
          holding_company_id: holding_company.id,
          start_date: current_month_time_dimension.start_date,
          end_date: future_month_time_dimension.end_date,
          format: :json

      expect(response_body).to include(revenue)
      expect(response_body).to include(pipeline)
    end
  end

  describe 'GET #spend_by_category' do
    let!(:pipeline_fact) do
      create(:advertiser_agency_pipeline_fact,
             time_dimension: future_month_time_dimension,
             advertiser_id: advertiser_with_assigned_category.id,
             agency_id: agency_with_assigned_category.id,
             company: company,
             weighted_amount: 10_000,
             unweighted_amount: 20_000)
    end

    let!(:revenue_fact) do
      create(:advertiser_agency_revenue_fact,
             time_dimension: current_month_time_dimension,
             advertiser_id: advertiser_with_assigned_category.id,
             agency_id: agency_with_assigned_category.id,
             company: company,
             revenue_amount: 10_000)
    end

    let(:revenue) do
      { category_name: category_option.name, sum: revenue_fact.revenue_amount }
    end

    let(:pipeline) do
      { category_name: category_option.name, sum:  pipeline_fact.weighted_amount }
    end

    let!(:client_connection) do
      create(:client_connection,
             advertiser_id: advertiser_with_assigned_category.id,
             agency_id: agency_with_assigned_category.id)
    end

    it 'returns spend by category' do
      get :spend_by_category,
          holding_company_id: holding_company.id,
          start_date: current_month_time_dimension.start_date,
          end_date: future_month_time_dimension.end_date,
          format: :json

      expect(response_body).to include(revenue)
      expect(response_body).to include(pipeline)
    end
  end

  describe 'GET #related_advertisers_without_spend' do
    let!(:client_connection) do
      create(:client_connection,
             advertiser_id: advertiser_account_dimension.id,
             agency_id: agency_account_dimension.id)
    end
    let!(:user) { create(:user, company: company) }
    let!(:client_member){ create(:client_member, share: 100, client: advertiser, user: user) }
    let!(:account_revenue_fact) { create(:account_revenue_fact,
                                         account_dimension: advertiser_account_dimension,
                                         revenue_amount: 10_000,
                                         company: company,
                                         time_dimension: current_month_time_dimension) }

    let(:open_pipeline) do
      {
        id: advertiser_account_dimension.id,
        advertiser_name: advertiser_account_dimension.name,
        seller_name: user.name,
        sum: account_revenue_fact.revenue_amount.to_s
      }
    end

    it 'returns open pipeline for advertiser without spend with max share user' do
      get :related_advertisers_without_spend,
          holding_company_id: holding_company.id,
          start_date: current_month_time_dimension.start_date,
          end_date: future_month_time_dimension.end_date,
          format: :json

      expect(response_body).to include(open_pipeline)
    end

  end

  describe 'GET #win_rate_by_category' do
    let!(:client_connection) do
      create(:client_connection,
             advertiser_id: advertiser_with_assigned_category.id,
             agency_id: agency_with_assigned_category.id)
    end

    let!(:won_deal) do
      create(:deal,
             agency: agency,
             advertiser: advertiser,
             stage: closed_won_stage,
             closed_at: current_month_time_dimension.start_date + 2.days,
             company: company)
    end

    let!(:lost_deal) do
      create(:deal,
             agency: agency,
             advertiser: advertiser,
             stage: closed_lost_stage,
             closed_at: current_month_time_dimension.start_date + 2.days,
             company: company)
    end

    let(:win_rate) do
      { name: category_option.name, win_rate: ((Deal.closed.won.count.to_f / (Deal.closed.won.count + Deal.closed.lost.count).to_f) * 100).to_s }
    end

    it 'returns win rate by categories' do
      get :win_rate_by_category,
          holding_company_id: holding_company.id,
          start_date: current_month_time_dimension.start_date,
          end_date: future_month_time_dimension.end_date,
          format: :json

      expect(response_body).to include(win_rate)
    end
  end

  describe 'GET #activity_history' do
    let!(:won_deal) do
      create(:deal,
             agency: agency,
             advertiser: advertiser,
             stage: closed_won_stage,
             closed_at: current_month_time_dimension.start_date + 2.days,
             company: company)
    end
    let!(:activity) { create(:activity, company: company, agency_id: agency_account_dimension.id, deal: won_deal) }
    let(:expected_activity) do
      {
         date: activity.happened_at,
         type: activity.activity_type_name,
         advertiser: agency_account_dimension.attributes.slice('id', 'name').symbolize_keys,
         comments: activity.comment,
         contacts: activity.contacts.pluck_to_hash(:id, :name).map(&:symbolize_keys)
      }
    end

    it 'returns list of agency activities' do
      get :activity_history,
          holding_company_id: holding_company.id,
          start_date: current_month_time_dimension.start_date,
          end_date: future_month_time_dimension.end_date,
          format: :json

      expect(response_body).to include(expected_activity)
    end

  end

  private

  def future_month_time_dimension
    @_future_month_time_dimension ||= create(:time_dimension,
                                           start_date: Date.today.beginning_of_month + 1.month,
                                           end_date: Date.today.end_of_month + 1.month,
                                           days_length: (Date.today.end_of_month - Date.today.beginning_of_month).to_i)
  end

  def current_month_time_dimension
    @_current_month_time_dimension ||= create(:time_dimension,
                                            start_date: Date.today.beginning_of_month,
                                            end_date: Date.today.end_of_month,
                                            days_length: (Date.today.end_of_month - Date.today.beginning_of_month).to_i)
  end

  def product
    @_product ||= create(:product)
  end

  def advertiser
    @_account ||= create(:client, :advertiser, holding_company: holding_company, company: company)
  end

  def agency
    @_agency ||= create(:client, :agency, holding_company: holding_company, company: company)
  end

  def product_dimension
    @_product_dimension ||= ProductDimension.find(product.id)
  end

  def user
    @_user ||= create(:user, company: company)
  end

  def advertiser_account_dimension
    @_advertiser_account_dimension ||= create(:account_dimension, :advertiser,
                                              id: advertiser.id,
                                              holding_company: holding_company,
                                              company: company)
  end

  def agency_account_dimension
    @_agency_account_dimension ||= create(:account_dimension, :agency,
                                          id: agency.id,
                                          holding_company: holding_company,
                                          company: company)
  end

  def advertiser_with_assigned_category
    @_advertiser_with_assigned_category ||= create(:account_dimension, :advertiser,
                                                   id: advertiser.id,
                                                   holding_company: holding_company,
                                                   company: company,
                                                   category_id: category_option.id)
  end

  def agency_with_assigned_category
    @_agency_with_assigned_category ||= create(:account_dimension, :agency,
                                               id: agency.id,
                                               holding_company: holding_company,
                                               company: company,
                                               category_id: category_option.id)
  end

  def category_option
    @_option ||= create(:option, option: Option.create(name: 'Option'), field: create(:field))
  end

  def holding_company
    @_holding_company ||= create(:holding_company)
  end

  def closed_won_stage
    @_won_stage ||= create(:won_stage, company: company, open: false)
  end

  def closed_lost_stage
    @_lost_stage ||= create(:lost_stage, company: company, open: false)
  end

  def convert_date(date)
    date.strftime('%Y-%m')
  end
end