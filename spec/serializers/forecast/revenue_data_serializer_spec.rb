require 'rails_helper'

describe Forecast::RevenueDataSerializer do
  before do
    content_fee
    content_fee2
    io_member
    io_member2
  end

  it 'revenue data serialized data' do
    expect(revenue_data.name).to eq(io.name)
    expect(revenue_data.advertiser).to eq(advertiser_name)
    expect(revenue_data.agency).to eq(agency_name)
    expect(revenue_data.budget).to eq(io.budget)
    expect(revenue_data.sum_period_budget).to eq(15000)
    expect(revenue_data.split_period_budget).to eq(9000)
  end

  private

  def revenue_data
    @_revenue_data ||= described_class.new(
      io,
      filter_start_date: time_period.start_date,
      filter_end_date: time_period.end_date,
      product_ids: products.collect(&:id),
      member_ids: [user.id]
    )
  end
  
  def company
    @_company ||= create :company, :fast_create_company
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

  def io
    @_io ||= create :io, company: company, start_date: '2015-04-01', end_date: '2015-06-30'
  end

  def io_member
    @_io_member ||= create :io_member, io: io, user: user, share: 60, from_date: '2015-04-01', to_date: '2015-06-30'
  end

  def io_member2
    @_io_member2 ||= create :io_member, io: io, user: user2, share: 40, from_date: '2015-04-01', to_date: '2015-06-30'
  end

  def content_fee
    @_content_fee ||= create :content_fee, io: io, product: products[0], budget: 10000, budget_loc: 10000
  end

  def content_fee2
    @_content_fee2 ||= create :content_fee, io: io, product: products[1], budget: 5000, budget_loc: 5000
  end

  def advertiser_name
    @_advertiser_name ||= io.advertiser.name rescue nil
  end

  def agency_name
    @_agency_name ||= io.agency.name rescue nil
  end
end