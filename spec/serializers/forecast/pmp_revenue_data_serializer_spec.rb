require 'rails_helper'

describe Forecast::PmpRevenueDataSerializer do
  before do
    pmp_item
    pmp_member
    pmp_member2
  end

  it 'pmp revenue data serialized data' do
    expect(pmp_revenue_data.name).to eq(pmp.name)
    expect(pmp_revenue_data.advertiser).to eq(advertiser_name)
    expect(pmp_revenue_data.agency).to eq(agency_name)
    expect(pmp_revenue_data.budget).to eq(pmp.budget)
    expect(pmp_revenue_data.start_date).to eq(pmp.start_date)
    expect(pmp_revenue_data.end_date).to eq(pmp.end_date)
    expect(pmp_revenue_data.sum_period_budget).to eq(10000.0)
    expect(pmp_revenue_data.split_period_budget).to eq(6000.0)
  end

  private

  def pmp_revenue_data
    @_pmp_revenue_data ||= described_class.new(
      pmp,
      filter_start_date: time_period.start_date,
      filter_end_date: time_period.end_date,
      product_ids: nil,
      member_ids: [user.id]
    )
  end
  
  def company
    @_company ||= Company.first
  end

  def team
    @_team ||= create :team, company: company
  end

  def user
    @_user ||= create :user, company: company, win_rate: 0.5, average_deal_size: 300, team: team
  end
  
  def user2
    @_user2 ||= create :user, company: company, win_rate: 0.5, average_deal_size: 300, team: team
  end

  def time_period
    @_time_period ||= create :time_period, company: company, start_date: '2015-01-01', end_date: '2015-12-31', period_type: 'year'
  end

  def product_family
    @_product_family ||= create :product_family, company: company
  end

  def products
    @_products ||= create_list :product, 2, product_family: product_family
  end

  def advertiser
    @_advertiser ||= create :client, company: company, address: address
  end

  def pmp
    @_pmp ||= create :pmp, company: company, start_date: '2015-04-01', end_date: '2015-06-30'
  end

  def pmp_member
    @_pmp_member ||= create :pmp_member, pmp: pmp, user: user, share: 60, from_date: '2015-04-01', to_date: '2015-06-30'
  end

  def pmp_member2
    @_pmp_member2 ||= create :pmp_member, pmp: pmp, user: user2, share: 40, from_date: '2015-04-01', to_date: '2015-06-30'
  end

  def pmp_item
    @_pmp_item ||= create :pmp_item, pmp: pmp, product: products[0], budget: 10000, budget_loc: 10000, pmp_type: PMP_TYPES[:guaranteed]
  end

  def advertiser_name
    @_advertiser_name ||= pmp.advertiser.name rescue nil
  end

  def agency_name
    @_agency_name ||= pmp.agency.name rescue nil
  end
end