require 'rails_helper'

describe Csv::PmpItemDailyActual, 'model' do
  describe 'validates attributes' do
    context 'with valid attributes' do
      it 'returns true' do
        csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual
        expect(csv_pmp_item_daily_actual.valid?).to be true
      end
    end

    context 'with invalid attributes' do
      it 'returns false' do
        csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual, impressions: 'invalid string'
        expect(csv_pmp_item_daily_actual.valid?).to be false
      end
    end
  end

  describe 'saves to pmp_item_daily_actuals' do
    context 'with duplicated deal-id, date' do
      it 'updates existing record' do
        csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual
        csv_pmp_item_daily_actual.save
        duplicated = build :csv_pmp_item_daily_actual, date: csv_pmp_item_daily_actual.date, ad_unit: 'Unit 1', ssp_deal_id: csv_pmp_item_daily_actual.ssp_deal_id, price: 1000, revenue_loc: 1000, impressions: 100, bids: 100
        duplicated.save
        csv_pmp_item_daily_actual.pmp_item_daily_actual.reload
        expect(csv_pmp_item_daily_actual.pmp_item_daily_actual.price).to eq(1000)
        expect(csv_pmp_item_daily_actual.pmp_item_daily_actual.revenue_loc).to eq(1000)
        expect(csv_pmp_item_daily_actual.pmp_item_daily_actual.impressions).to eq(100)
        expect(csv_pmp_item_daily_actual.pmp_item_daily_actual.bids).to eq(100)
      end
    end

    context 'with new data' do
      it 'creates new record' do
        csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual, win_rate: nil
        csv_pmp_item_daily_actual.save
        expect(csv_pmp_item_daily_actual.pmp_item_daily_actual).to be_persisted
      end
    end
  end

  describe 'import csv file' do
    before do
      pmp_item
    end

    it 'creates pmp_item_daily_actuals' do
      expect {
        described_class.import(file.path, user.id, 'pmp_item_daily_actual.csv')
      }.to change(PmpItemDailyActual, :count).by(2)
    end

    it 'creates csv import log' do
      expect {
        described_class.import(file_with_error.path, user.id, 'pmp_item_daily_actual.csv')
      }.to change(CsvImportLog, :count).by(1)
      import_log = CsvImportLog.find_by(company_id: user.company.id, object_name: 'pmp_item_daily_actual', source: 'ui', file_source: 'pmp_item_daily_actual.csv')
      expect(import_log.error_messages.as_json).to include({"row" => 2, "message" => ['Bids is not a number']})
      expect(import_log.rows_imported).to eq(1)
      expect(import_log.rows_failed).to eq(1)
      expect(import_log.rows_processed).to eq(2)
    end

    it 'generate pmp item monthly actual' do
      expect {
        described_class.import(file.path, user.id, 'pmp_item_daily_actual.csv')
      }.to change(PmpItemMonthlyActual, :count).by(1)
      pmp_item_monthly_actual = pmp_item.pmp_item_monthly_actuals.first
      expect(pmp_item_monthly_actual.amount_loc).to eq(1500)
      expect(pmp_item_monthly_actual.start_date).to eq(Date.strptime('11/20/2017', "%m/%d/%Y"))
      expect(pmp_item_monthly_actual.end_date).to eq(Date.strptime('11/21/2017', "%m/%d/%Y"))
    end

    it 'calculate pmp item budgets, run_rates' do
      described_class.import(file.path, user.id, 'pmp_item_daily_actual.csv')
      pmp_item.reload
      expect(pmp_item.budget_delivered_loc).to eq(1500)
      expect(pmp_item.budget_remaining_loc).to eq(500)
      expect(pmp_item.run_rate_7_days).to be_nil
      expect(pmp_item.run_rate_30_days).to be_nil
    end

    it 'calculate pmp end date' do
      pmp_item.pmp.update(end_date: Date.strptime('11/5/2017', "%m/%d/%Y"))
      described_class.import(file.path, user.id, 'pmp_item_daily_actual.csv')
      expect(pmp_item.pmp.reload.end_date).to eq(Date.strptime('11/21/2017', "%m/%d/%Y"))
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
    @_pmp_item ||= create :pmp_item, ssp_deal_id: 'ssp001', budget_loc: 2000, run_rate_7_days: 900, run_rate_30_days: 500
  end

  def file
    @_file ||= Tempfile.open([Dir.tmpdir, ".csv"]) do |f|
      begin
        csv = CSV.new(f)
        csv << ['Deal-ID', 'Date', 'Ad Unit', 'Bids', 'Impressions', 'Win Rate', 'eCPM', 'Revenue', 'Render Rate', 'Currency']
        csv << ['ssp001', '11/20/17', 'Unit 4', 9, 99, nil, 99, 1000, 9.9, 'USD']
        csv << ['ssp001', '11/21/2017', 'Unit 4', 9, 99, 61.05, 99, 500, 9.9, 'USD']
      ensure
        f.close(unlink_now=false)
      end
    end
  end

  def file_with_error
    @_file_with_error ||= Tempfile.open([Dir.tmpdir, ".csv"]) do |f|
      begin
        csv = CSV.new(f)
        csv << ['Deal-ID', 'Date', 'Ad Unit', 'Bids', 'Impressions', 'Win Rate', 'eCPM', 'Revenue', 'Render Rate', 'Currency']
        csv << ['ssp001', '11/20/17', 'Unit 4', 9, 99, 60, 99, 999, 9.9, 'USD']
        csv << ['ssp001', '11/21/2017', 'Unit 4', 'String', 99, 60, 99, 999, 19.9, 'USD']
      ensure
        f.close(unlink_now=false)
      end
    end
  end
end

RSpec.describe Csv::PmpItemDailyActual, 'validations' do
  it 'is valid with ssp_deal_id with matching pmp_item and date with correct format' do
    csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual
    expect(csv_pmp_item_daily_actual).to be_valid
  end

  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:ad_unit) }
  it { should validate_presence_of(:bids) }
  it { should validate_presence_of(:impressions) }
  it { should validate_numericality_of(:impressions) }
  it { should validate_numericality_of(:bids) }
  it { should validate_numericality_of(:win_rate) }
  it { should validate_numericality_of(:render_rate) }
  it { should allow_value(nil).for(:win_rate) }
  it { should allow_value(nil).for(:render_rate) }

  it 'is invalid without ssp_deal_id' do
    csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual
    csv_pmp_item_daily_actual.ssp_deal_id = ''
    expect(csv_pmp_item_daily_actual).not_to be_valid
    expect(csv_pmp_item_daily_actual.error_messages).to include("Deal-ID can't be blank")
    expect(csv_pmp_item_daily_actual.error_messages.count).to eq(1)
  end

  it 'is invalid with no matching ssp_deal_id' do
    csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual
    csv_pmp_item_daily_actual.ssp_deal_id = 'no matching'
    expect(csv_pmp_item_daily_actual).not_to be_valid
    expect(csv_pmp_item_daily_actual.error_messages).to include("Pmp item with Deal-Id no matching could not be found")
  end

  it 'is invalid with wrong date format' do
    csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual, date: '99/99/9999'
    expect(csv_pmp_item_daily_actual).not_to be_valid
    expect(csv_pmp_item_daily_actual.error_messages).to include("Date - 99/99/9999 must be in valid date format")
  end

  it 'is invalid without eCPM' do
    csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual, price: nil
    expect(csv_pmp_item_daily_actual).not_to be_valid
  end

  it 'is invalid with non-numeric eCPM' do
    csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual, price: 'string'
    expect(csv_pmp_item_daily_actual).not_to be_valid
  end


  it 'is invalid without revenue_loc' do
    csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual, revenue_loc: nil
    expect(csv_pmp_item_daily_actual).not_to be_valid
  end

  it 'is invalid with non-numeric revenue_loc' do
    csv_pmp_item_daily_actual = build :csv_pmp_item_daily_actual, revenue_loc: 'string'
    expect(csv_pmp_item_daily_actual).not_to be_valid
  end
end
