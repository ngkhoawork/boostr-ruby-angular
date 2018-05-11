require 'rails_helper'

describe Users::CompanyInfoSerializer do
  it 'serializes basic user and company enabled data' do
    expect(serializer.id).to eq(user.id)
    expect(serializer.company_id).to eq(company.id)
    expect(serializer.email).to eq('john.doe@boostr.com')
    expect(serializer.first_name).to eq('John')
    expect(serializer.last_name).to eq('Doe')
    expect(serializer.name).to eq('John Doe')
    expect(serializer.team_id).to eq(team.id)
    expect(serializer.is_leader).to eq(false)
    expect(serializer.office).to eq('office 1')
    expect(serializer.is_admin).to eq(false)
    expect(serializer.company_egnyte_enabled).to eq(false)
    expect(serializer.company_forecast_gap_to_quota_positive).to eq(true)
    expect(serializer.company_influencer_enabled).to eq(true)
    expect(serializer.company_net_forecast_enabled).to eq(true)
    expect(serializer.default_currency).to eq('USD')
    expect(serializer.has_forecast_permission).to eq(true)
    expect(serializer.has_multiple_sales_process).to eq(false)
    expect(serializer.leads_enabled).to eq(true)
    expect(serializer.product_option1).to eq('Option1')
    expect(serializer.product_option2).to eq('Option2')
    expect(serializer.product_option1_enabled).to eq(true)
    expect(serializer.product_option2_enabled).to eq(true)
    expect(serializer.product_options_enabled).to eq(true)
    expect(serializer.revenue_requests_access).to eq(true)
  end

  private

  def serializer
    @_serializer ||= described_class.new(user)
  end

  def company
    @_company ||= create :company,  forecast_gap_to_quota_positive: true,
                                    influencer_enabled: true,
                                    logi_enabled: true,
                                    enable_net_forecasting: true,
                                    product_options_enabled: true,
                                    product_option1_enabled: true,
                                    product_option2_enabled: true
  end

  def leader
    create :user
  end

  def team
    @_team ||= create :team, leader: leader
  end

  def user
    @_user ||= create :user,  company: company,
                              team: team,
                              first_name: 'John',
                              last_name: 'Doe',
                              email: 'john.doe@boostr.com',
                              office: 'office 1',
                              agreements_enabled: true,
                              contracts_enabled: true,
                              revenue_requests_access: true,
                              leads_enabled: true
  end
end
