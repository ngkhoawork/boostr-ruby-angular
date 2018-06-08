require 'rails_helper'

describe Csv::PmpItemDailyActual, 'model' do
  let!(:company) { create :company }

  describe 'import csv file' do
    before { pmp_item }

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
      expect(import_log.error_messages.as_json).to include({"row" => 2, "message" => ['Ad requests is not a number']})
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
      expect(pmp_item.run_rate_7_days).to be_zero
      expect(pmp_item.run_rate_30_days).to be_zero
    end

    it 'calculate pmp end date' do
      pmp_item.pmp.update(end_date: Date.strptime('11/5/2017', "%m/%d/%Y"))
      described_class.import(file.path, user.id, 'pmp_item_daily_actual.csv')
      expect(pmp_item.pmp.reload.end_date).to eq(Date.strptime('11/21/2017', "%m/%d/%Y"))
    end

    context 'using ssp advertiser' do
      before do
        client
        ssp_advertiser
      end

      it 'finds advertiser among company clients and set' do
        described_class.import(file.path, user.id, 'pmp_item_daily_actual.csv')
        expect(pmp_item.pmp_item_daily_actuals&.first&.advertiser_id).to eq(client.id)
      end

      it 'finds advertiser from ssp_advertisers and set' do
        described_class.import(file.path, user.id, 'pmp_item_daily_actual.csv')
        expect(pmp_item.pmp_item_daily_actuals&.last&.advertiser_id).to eq(client.id)
      end
    end
  end

  private

  def user
    @_user ||= create :user, company: company, email: 'test@user.com'
  end

  def pmp_item
    @_pmp_item ||= create :pmp_item, ssp_deal_id: 'ssp001', budget_loc: 2000, run_rate_7_days: 900, run_rate_30_days: 500
  end

  def client
    @_client ||= create :client, name: 'googlex', company: company
  end

  def ssp_advertiser
    @_ssp_advertiser ||= create :ssp_advertiser, name: 'yahoo', client: client, company: company, ssp: pmp_item.ssp
  end

  def file
    @_file ||= Tempfile.open([Dir.tmpdir, ".csv"]) do |f|
      begin
        csv = CSV.new(f)
        csv << ['Deal-ID', 'Date', 'Ad Unit', 'Ad Requests', 'Impressions', 'Win Rate', 'eCPM', 'Revenue', 'Currency', 'SSP Advertiser']
        csv << ['ssp001', '11/20/17', 'Unit 4', 9, 99, nil, 99, 1000, 'USD', 'googlex']
        csv << ['ssp001', '11/21/2017', 'Unit 4', 9, 99, 61.05, 99, 500, 'USD', 'yahoo']
      ensure
        f.close(unlink_now=false)
      end
    end
  end

  def file_with_error
    @_file_with_error ||= Tempfile.open([Dir.tmpdir, ".csv"]) do |f|
      begin
        csv = CSV.new(f)
        csv << ['Deal-ID', 'Date', 'Ad Unit', 'Ad Requests', 'Impressions', 'Win Rate', 'eCPM', 'Revenue', 'Currency']
        csv << ['ssp001', '11/20/17', 'Unit 4', 9, 99, 60, 99, 999, 'USD']
        csv << ['ssp001', '11/21/2017', 'Unit 4', 'String', 99, 60, 99, 999, 'USD']
      ensure
        f.close(unlink_now=false)
      end
    end
  end
end
