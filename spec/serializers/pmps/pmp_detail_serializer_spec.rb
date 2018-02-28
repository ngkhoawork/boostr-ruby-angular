require 'rails_helper'

describe Pmps::PmpDetailSerializer do
  it 'serialize pmp details' do
    expect(pmp_detail_serializer.id).to eq(pmp.id)
    expect(pmp_detail_serializer.name).to eq(pmp.name)
    expect(pmp_detail_serializer.deal_id).to eq(pmp.deal_id)
    expect(pmp_detail_serializer.budget).to eq(pmp.budget)
    expect(pmp_detail_serializer.budget_loc).to eq(pmp.budget_loc)
    expect(pmp_detail_serializer.budget_delivered).to eq(pmp.budget_delivered)
    expect(pmp_detail_serializer.budget_remaining).to eq(pmp.budget_remaining)
    expect(pmp_detail_serializer.start_date).to eq(pmp.start_date)
    expect(pmp_detail_serializer.end_date).to eq(pmp.end_date)
    expect(pmp_detail_serializer.advertiser.symbolize_keys).to eq(id: pmp.advertiser.id, name: pmp.advertiser.name)
    expect(pmp_detail_serializer.agency.symbolize_keys).to eq(id: pmp.agency.id, name: pmp.agency.name)
    expect(pmp_detail_serializer.currency.symbolize_keys).to eq(curr_cd: pmp.currency.curr_cd, curr_symbol: pmp.currency.curr_symbol)
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

  describe 'without currency' do
    it 'returns nil for currency' do
      pmp.curr_cd = nil
      serializer = described_class.new(pmp)
      expect(serializer.currency).to eq(nil)
    end
  end

  private

  def pmp_detail_serializer
    @_pmp_detail_serializer ||= described_class.new(pmp)
  end

  def pmp
    @_pmp ||= create :pmp, company: company
  end

  def company
    @_company ||= create :company
  end
end