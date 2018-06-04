require 'rails_helper'

describe Api::DashboardsController do
  let!(:company) { create :company }
  let!(:time_period) do
    create :time_period,
            name: 'Q3',
            period_type: 'quarter',
            start_date: '2017-06-01',
            end_date: '2017-09-30'
  end

  let!(:next_time_period) do
    create :time_period,
            name: 'Q4',
            period_type: 'quarter',
            start_date: '2017-10-01',
            end_date: '2017-12-31'
  end

  before do
    Timecop.freeze(2017, 7, 30)
    create :deal_member, user: user, deal: deal
    sign_in user
  end

  after(:all) do
    Timecop.return
  end

  describe 'GET #show' do
    it 'returns json for the dashboard' do
      get :show, format: :json

      response_json = JSON.parse(response.body)

      expect(response).to be_success
      expect(response_json['forecast']['amount']).to_not be_nil
      expect(response_json['deals'].length).to eq(1)
    end

    it 'returns a nil forecast if there is no current time_period' do
      company.time_periods.delete_all

      get :show, format: :json

      expect(response).to be_success
      expect(json_response['forecast']).to be_nil
      expect(json_response['next_quarter_forecast']).to be_nil
      expect(json_response['this_year_forecast']).to be_nil
    end
  end

  private

  def user
    @_user ||= create :user, company: company
  end

  def parent_team
    @_parent_team ||= create :parent_team, company: company, leader: user
  end

  def deal
    @_deal ||= create :deal, company: company
  end
end
