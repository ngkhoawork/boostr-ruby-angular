require 'rails_helper'

describe Importers::ContractsService do
  describe '#perform' do
    after(:each) { FileUtils.rm(file.path) if File.exist?(file.path) }
    subject { instance.perform }

    before do
      contract
    end

    it 'creates new contract' do
      expect{subject}.to change{Contract.count}.by(1)
    end

    it 'updates contract' do
      expect{subject}.to change{Contract.last.amount}.to(5000)
    end

    it 'saves import logs' do
      expect{subject}.to change{CsvImportLog.count}.by(1)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def instance
    described_class.new({company_id: company.id, file: file.path})
  end

  def currency
    @_currency ||= create :currency
  end

  def contract
    @_contract ||= create :contract, company: company, type: type_option, name: 'contract', amount: '1000'
  end

  def type_field
    @_type_field ||= create :field, subject_type: 'Contract', name: 'Type', company: company
  end

  def type_option
    @_type_option ||= create :option, company: company, name: 'Contract Type 1', field: type_field
  end

  def status_field
    @_status_field ||= create :field, subject_type: 'Contract', name: 'Status', company: company
  end

  def status_option
    @_status_option ||= create :option, company: company, name: 'Contract Status 1', field: status_field
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def publisher
    @_publisher ||= create :publisher, company: company, name: 'publisher'
  end

  def advertiser
    @_advertiser ||= create :client, :advertiser, name: 'advertiser'
  end

  def agency
    @_agency ||= create :client, :agency, name: 'agency'
  end

  def holding_company
    @_holding_company ||= create :holding_company, name: 'test company'
  end

  def file
    @_file ||= Tempfile.open([Dir.tmpdir, '.csv']) do |fh|
      begin
        csv = CSV.new(fh)
        csv << ['Name', 'Created Date', 'Restricted', 'Type', 'Status', 'Auto Renew', 'Start Date', 'End Date', 'Auto Notifications', 'Currency', 'Amount', 'Description', 'Days Notice Required', 'Deal', 'Deal ID', 'Publisher', 'Agency', 'Advertiser', 'Agency Holding']
        csv << ['contract', '05/02/2018', '1', type_option.name, status_option.name, '1', '05/01/2018', '06/30/2018', '1', currency.curr_cd, '5000', 'test', '50', deal.name, deal.id, publisher.name, agency.name, advertiser.name, holding_company.name]
        csv << ['contract2', '05/02/2018', '1', type_option.name, status_option.name, '1', '05/01/2018', '06/30/2018', '1', currency.curr_cd, '5000', 'test', '50', deal.name, deal.id, publisher.name, agency.name, advertiser.name, holding_company.name]
      ensure
        fh.close()
      end
    end
  end
end
