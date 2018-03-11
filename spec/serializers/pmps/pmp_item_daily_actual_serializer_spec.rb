require 'rails_helper'

describe Pmps::PmpItemDailyActualSerializer do
  let!(:company) { create :company }

  it 'serialize pmp_item_daily_actual' do
    expect(serializer.id).to eq(pmp_item_daily_actual.id)
    expect(serializer.pmp_item_id).to eq(pmp_item_daily_actual.pmp_item_id)
    expect(serializer.date).to eq(pmp_item_daily_actual.date)
    expect(serializer.ad_unit).to eq(pmp_item_daily_actual.ad_unit)
    expect(serializer.price).to eq(pmp_item_daily_actual.price)
    expect(serializer.revenue).to eq(pmp_item_daily_actual.revenue)
    expect(serializer.revenue_loc).to eq(pmp_item_daily_actual.revenue_loc)
    expect(serializer.impressions).to eq(pmp_item_daily_actual.impressions)
    expect(serializer.win_rate).to eq(pmp_item_daily_actual.win_rate)
    expect(serializer.ad_requests).to eq(pmp_item_daily_actual.ad_requests)
  end

  private

  def serializer
    @_serializer ||= described_class.new(pmp_item_daily_actual)
  end

  def pmp_item_daily_actual
    @_pmp_item_daily_actual ||= create :pmp_item_daily_actual
  end
end