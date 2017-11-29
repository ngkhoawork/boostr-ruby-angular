require 'rails_helper'

describe Csv::PmpItemDailyActual do
  describe '.import' do
    before do
      pmp_item
    end

    it 'creates new pmp_item_daily_actual' do
      expect {
        described_class.import(file, user.id, 'pmp_item_daily_actual.csv')
      }.to change(PmpItemDailyActual, :count).by(2)

      pmp_item_daily_actual = PmpItemDailyActual.last

      expect(pmp_item_daily_actual.date.strftime('%m/%d/%y')).to eq('11/21/17')
      expect(pmp_item_daily_actual.ad_unit).to eq('Unit 4')
      expect(pmp_item_daily_actual.bids).to eq(9)
      expect(pmp_item_daily_actual.impressions).to eq(99)
      expect(pmp_item_daily_actual.win_rate).to eq(60)
      expect(pmp_item_daily_actual.price).to eq(99)
      expect(pmp_item_daily_actual.revenue_loc).to eq(999)
      expect(pmp_item_daily_actual.pmp_item_id).to eq(pmp_item.id)
    end

    context 'with duplicated data' do
      let!(:pmp_item_daily_actual) { create :pmp_item_daily_actual, pmp_item: pmp_item, date: Date.new(2017, 11, 20) }

      it 'update existing pmp_item_daily_actual' do
        expect {
          described_class.import(file, user.id, 'pmp_item_daily_actual.csv')
        }.to change(PmpItemDailyActual, :count).by(1)

        pmp_item_daily_actual.reload
        expect(pmp_item_daily_actual.ad_unit).to eq('Unit 4')
        expect(pmp_item_daily_actual.bids).to eq(9)
        expect(pmp_item_daily_actual.impressions).to eq(99)
        expect(pmp_item_daily_actual.win_rate).to eq(60)
        expect(pmp_item_daily_actual.price).to eq(99)
        expect(pmp_item_daily_actual.revenue_loc).to eq(999)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company, email: 'test@user.com'
  end

  def pmp_item
    @_pmp_item ||= create :pmp_item, ssp_deal_id: 'ssp001'
  end

  def file
    @_file = CSV.generate do |csv|
      csv << ['Deal-ID', 'Date', 'Ad Unit', 'Bids', 'Impressions', 'Win Rate', 'eCPM', 'Revenue', 'Currency']
      csv << ['ssp001', '11/20/17', 'Unit 4', 9, 99, 60, 99, 999, 'USD']
      csv << ['ssp001', '11/21/2017', 'Unit 4', 9, 99, 60, 99, 999, 'USD']
    end
  end
end
