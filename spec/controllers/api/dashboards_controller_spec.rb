require 'rails_helper'

describe Api::DashboardsController do
  before do
    Timecop.freeze(2017, 7, 30)
    create :deal_member, user: user, deal: deal
    sign_in user
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

      expect(response).to_not be_success
      response_json = JSON.parse(response.body)
      expect(response_json['errors']).to eq 'Error happened when company didn\'t have time periods of type Quarter'
    end
  end

  private

  def company
    @_company ||= create :company, time_periods: [time_period, next_time_period]
  end

  def user
    @_user ||= create :user, company: company
  end

  def parent_team
    @_parent_team ||= create :parent_team, company: company, leader: user
  end

  def time_period
    @_time_period ||= create :time_period,
                             name: 'Q3',
                             period_type: 'quarter',
                             start_date: '2017-06-01',
                             end_date: '2017-09-30'
  end

  def next_time_period
    @_next_time_period ||= create :time_period,
                                  name: 'Q4',
                                  period_type: 'quarter',
                                  start_date: '2017-10-01',
                                  end_date: '2017-12-31'
  end

  def deal
    @_deal ||= create :deal, company: company
  end
end
