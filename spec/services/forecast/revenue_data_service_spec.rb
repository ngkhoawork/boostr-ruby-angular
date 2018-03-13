require 'rails_helper'

describe Forecast::RevenueDataService do
  before do
    content_fee
    content_fee2
    io_member
    io_member2
  end

  it 'return correct revenue data service for a member' do
    params = {
      time_period_id: time_period.id,
      member_id: user.id
    };
    expect(
      revenue_data_service(company, params).perform.object.to_a
    ).to eq([io])
  end

  it 'return correct revenue data service for a team' do
    params = {
      time_period_id: time_period.id,
      team_id: team.id
    };
    expect(
      revenue_data_service(company, params).perform.object.count
    ).to eq(2)
  end

  it 'return correct revenue data service for a product' do
    params = {
      time_period_id: time_period.id,
      team_id: team.id,
      product_id: products[1].id
    };
    expect(
      revenue_data_service(company, params).perform.object.to_a
    ).to eq([io2])
  end
  
  it 'return correct revenue data service for a product family' do
    params = {
      time_period_id: time_period.id,
      team_id: team.id,
      product_family_id: product_family.id
    };
    expect(
      revenue_data_service(company, params).perform.object.count
    ).to eq(2)
  end

  private

  def revenue_data_service(company, params)
    @revenue_data_service ||= described_class.new(company, params)
  end

  def company
    @_company ||= create :company
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

  def io
    @_io ||= create :io, company: company, start_date: '2015-04-01', end_date: '2015-06-30'
  end

  def io2
    @_io2 ||= create :io, company: company, start_date: '2015-04-01', end_date: '2015-06-30'
  end

  def io_member
    @_io_member ||= create :io_member, io: io, user: user, share: 60, from_date: '2015-04-01', to_date: '2015-06-30'
  end

  def io_member2
    @_io_member2 ||= create :io_member, io: io2, user: user2, share: 40, from_date: '2015-04-01', to_date: '2015-06-30'
  end

  def content_fee
    @_content_fee ||= create :content_fee, io: io, product: products[0], budget: 10000, budget_loc: 10000
  end

  def content_fee2
    @_content_fee2 ||= create :content_fee, io: io2, product: products[1], budget: 5000, budget_loc: 5000
  end
end