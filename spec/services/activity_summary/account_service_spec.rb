require 'rails_helper'

describe ActivitySummary::AccountService do
  before { create_activities }

  it 'has proper data for activity summary by account' do
    client_activities = account_service[:client_activities]
    advertiser_activities = client_activities.select { |el| el[:client_id].eql? advertiser.id }.first
    agency_activities = client_activities.select { |el| el[:client_id].eql? agency.id }.first

    total_activity_report = account_service[:total_activity_report]

    expect(advertiser_activities['Pitch']).to eq 5
    expect(advertiser_activities[:total]).to eq 5

    expect(agency_activities['Email']).to eq 3
    expect(agency_activities[:total]).to eq 3

    expect(total_activity_report['Pitch']).to eq 5
    expect(total_activity_report['Email']).to eq 3
    expect(total_activity_report[:total]).to eq 8
  end

  private

  def account_service
   @_account_service ||= described_class.new(user, params: params).perform
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def advertiser
    @_advertiser ||= create :client, company: company, client_type_id: client_advertiser_type_id
  end

  def create_agency
    @_agency ||= create :client, values: [create_agency_value], company: company, client_type_id: client_agency_type_id
  end

  def create_agency_value
    Value.create(field_id: client_type, option_id: agency_type, company: company)
  end

  def client_type
    client_type_field(company).id
  end

  def agency_type
    agency_type_id(company)
  end

  def agency
    create_agency
  end

  def params
    {
      start_date: '01/02/2017',
      end_date: '09/02/2017'
    }
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def create_activities
    create_advertiser_activities
    create_agency_activities
  end

  def create_advertiser_activities
    create_list(
      :activity,
      5,
      activity_type: company.activity_types.by_name('Pitch'),
      client: advertiser,
      company: company,
      deal: deal,
      happened_at: Date.new(2017, 2, 2)
    )
  end

  def create_agency_activities
    create_list(
      :activity,
      3,
      activity_type: company.activity_types.by_name('Email'),
      agency: agency,
      company: company,
      deal: deal,
      happened_at: Date.new(2017, 2, 4)
    )
  end

  def client_advertiser_type_id
    Client.advertiser_type_id(company)
  end

  def client_agency_type_id
    Client.agency_type_id(company)
  end
end
