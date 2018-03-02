require 'rails_helper'

describe Pmp::FilteredRevenueProductDataService do
  before do
    pmp_item_daily_actual
    pmp_item_daily_actual2
    pmp_item_daily_actual3
    pmp_member
    pmp_member2
  end

  it 'return correct filtered revenue data service' do
    result = filtered_revenue_data_service(
        pmp,
        time_period.start_date,
        time_period.end_date,
        [pmp_member.user_id],
        nil
      ).perform
    product_id = products[0].id
    expect(result[0]).to eq(15000)
    expect(result[1]).to eq(9000)
    expect(result[2][product_id][:in_period_amt]).to eq(300.0)
    expect(result[2][product_id][:in_period_split_amt]).to eq(180)
  end
  
  it 'return correct filtered revenue data service for one product & one member' do
    result = filtered_revenue_data_service(
        pmp,
        time_period.start_date,
        time_period.end_date,
        [pmp_member.user_id],
        [products[0].id]
      ).perform
    product_id = products[0].id
    expect(result[0]).to eq(300)
    expect(result[1]).to eq(180)
    expect(result[2][product_id][:in_period_amt]).to eq(300.0)
    expect(result[2][product_id][:in_period_split_amt]).to eq(180)
  end
  
  it 'return correct filtered revenue data service for multiple products & one member' do
    result = filtered_revenue_data_service(
        pmp,
        time_period.start_date,
        time_period.end_date,
        [pmp_member2.user_id],
        nil
      ).perform
    product_id = products[0].id
    expect(result[0]).to eq(15000)
    expect(result[1]).to eq(6000.0)
    expect(result[2][product_id][:in_period_amt]).to eq(300.0)
    expect(result[2][product_id][:in_period_split_amt]).to eq(120)
  end
  
  it 'return correct filtered revenue data service for multiple products & multiple members' do
    result = filtered_revenue_data_service(
        pmp,
        time_period.start_date,
        time_period.end_date,
        [pmp_member.user_id, pmp_member2.user_id],
        nil
      ).perform
    product_id = products[0].id
    expect(result[0]).to eq(15000)
    expect(result[1]).to eq(15000)
    expect(result[2][product_id][:in_period_amt]).to eq(600.0)
    expect(result[2][product_id][:in_period_split_amt]).to eq(300)
  end

  private

  def filtered_revenue_data_service(pmp, start_date, end_date, member_ids, product_ids)
    @filtered_pmp_revenue_data_service ||= described_class.new(pmp, start_date, end_date, member_ids, product_ids)
  end

  def company
    @_company ||= Company.first
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

  def pmp_item2
    @_pmp_item2 ||= create :pmp_item, pmp: pmp, product: products[1], budget: 5000, budget_loc: 5000, pmp_type: PMP_TYPES[:guaranteed]
  end

  def pmp_item_daily_actual
    @_pmp_item_daily_actual ||= create :pmp_item_daily_actual, pmp_item: pmp_item, date: '2015-04-01', revenue: 100, revenue_loc: 100
  end

  def pmp_item_daily_actual2
    @_pmp_item_daily_actual2 ||= create :pmp_item_daily_actual, pmp_item: pmp_item, date: '2015-04-02', revenue: 200, revenue_loc: 200
  end

  def pmp_item_daily_actual3
    @_pmp_item_daily_actual3 ||= create :pmp_item_daily_actual, pmp_item: pmp_item2, date: '2015-04-01', revenue: 500, revenue_loc: 500
  end
end