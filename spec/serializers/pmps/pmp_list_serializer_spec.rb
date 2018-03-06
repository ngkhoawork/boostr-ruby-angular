require 'rails_helper'

describe Pmps::PmpListSerializer do
  it 'serialize for the pmp list' do
    expect(serializer.id).to eq(pmp.id)
    expect(serializer.name).to eq(pmp.name)
    expect(serializer.deal_id).to eq(pmp.deal_id)
    expect(serializer.advertiser.symbolize_keys).to eq(id: pmp.advertiser.id, name: pmp.advertiser.name)
    expect(serializer.agency.symbolize_keys).to eq(id: pmp.agency.id, name: pmp.agency.name)
    expect(serializer.budget_loc).to eq(pmp.budget_loc)
    expect(serializer.start_date).to eq(pmp.start_date)
    expect(serializer.currency.symbolize_keys).to eq(curr_cd: pmp.currency.curr_cd, curr_symbol: pmp.currency.curr_symbol)
  end

  describe 'without advertiser' do
    it 'returns nil for advertiser' do
      pmp.advertiser = nil
      serializer = described_class.new(pmp)
      expect(serializer.advertiser).to eq(nil)
    end
  end

  describe 'without agency' do 
    it 'returns nil for agency' do
      pmp.agency = nil
      serializer = described_class.new(pmp)
      expect(serializer.agency).to eq(nil)
    end
  end

  private

  def serializer
    @_serializer ||= described_class.new(pmp)
  end

  def pmp
    @_pmp ||= create :pmp
  end
end