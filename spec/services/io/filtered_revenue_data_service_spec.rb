require 'rails_helper'

describe Io::FilteredRevenueDataService do
  before do
    content_fee
    content_fee2
    io_member
    io_member2
  end

  it 'return correct filtered revenue data service' do
    expect(
      filtered_revenue_data_service(
        io,
        time_period.start_date,
        time_period.end_date,
        [io_member.user_id],
        nil
      ).perform
    ).to eq([15000, 9000])
  end
  
  it 'return correct filtered revenue data service for one product & one member' do
    expect(
      filtered_revenue_data_service(
        io,
        time_period.start_date,
        time_period.end_date,
        [io_member.user_id],
        [products[0].id]
      ).perform
    ).to eq([10000, 6000])
  end
  
  it 'return correct filtered revenue data service for multiple products & one member' do
    expect(
      filtered_revenue_data_service(
        io,
        time_period.start_date,
        time_period.end_date,
        [io_member.user_id],
        products.collect(&:id)
      ).perform
    ).to eq([15000, 9000])
  end
  
  it 'return correct filtered revenue data service for multiple products & multiple members' do
    expect(
      filtered_revenue_data_service(
        io,
        time_period.start_date,
        time_period.end_date,
        [io_member.user_id, io_member2.user_id],
        products.collect(&:id)
      ).perform
    ).to eq([15000, 15000])
  end

  private

  def filtered_revenue_data_service(io, start_date, end_date, member_ids, product_ids)
    @filtered_revenue_data_service ||= described_class.new(io, start_date, end_date, member_ids, product_ids)
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, win_rate: 0.5, average_deal_size: 300
  end
  
  def user2
    @_user2 ||= create :user, win_rate: 0.5, average_deal_size: 300
  end

  def time_period
    @_time_period ||= create :time_period, start_date: '2015-01-01', end_date: '2015-12-31', period_type: 'year'
  end

  def products
    @_products ||= create_list :product, 2
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
end