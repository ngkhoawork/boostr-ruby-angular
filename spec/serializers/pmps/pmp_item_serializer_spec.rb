require 'rails_helper'

describe Pmps::PmpItemSerializer do
  let!(:company) { create :company }

  it 'serialize pmp_item' do
    expect(serializer.id).to eq(pmp_item.id)
    expect(serializer.ssp_deal_id).to eq(pmp_item.ssp_deal_id)
    expect(serializer.ssp.symbolize_keys).to eq(id: pmp_item.ssp.id, name: pmp_item.ssp.name)
    expect(serializer.budget).to eq(pmp_item.budget)
    expect(serializer.budget_loc).to eq(pmp_item.budget_loc)
    expect(serializer.budget_delivered).to eq(pmp_item.budget_delivered)
    expect(serializer.budget_delivered_loc).to eq(pmp_item.budget_delivered_loc)
    expect(serializer.budget_remaining).to eq(pmp_item.budget_remaining)
    expect(serializer.budget_remaining_loc).to eq(pmp_item.budget_remaining_loc)
  end

  describe 'without ssp' do
    it 'returns nil for ssp' do
      pmp_item.ssp = nil
      serializer = described_class.new(pmp_item)
      expect(serializer.ssp).to eq(nil)
    end
  end

  private

  def serializer
    @_serializer ||= described_class.new(pmp_item)
  end

  def pmp_item
    @_pmp_item ||= create :pmp_item, budget_delivered: 99, budget_delivered_loc: 99, budget_remaining: 900, budget_remaining_loc: 900
  end
end