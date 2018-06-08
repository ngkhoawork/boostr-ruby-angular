require 'rails_helper'

describe Importers::DealProductBudgetsService do
  describe '#perform' do
    after(:each) { FileUtils.rm(file.path) if File.exist?(file.path) }
    subject { instance.perform }

    it 'creates new deal product monthly budget' do
      expect{subject}.to change{DealProductBudget.count}.by(3)
    end

    it 'updates deal product budgets' do
      expect{subject}.to change{deal.deal_products&.first&.budget}.to(100)
    end

    it 'updates deal budgets' do
      expect{subject}.to change{deal.reload.budget}.from(0).to(100)
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

  def deal
    @_deal ||= create :deal, company: company, start_date: '2018-01-01', end_date: '2018-03-31', budget: 0
  end

  def product
    @_product ||= create :product, company: company, name: 'boostr'
  end

  def file
    @_file ||= Tempfile.open([Dir.tmpdir, '.csv']) do |fh|
      begin
        csv = CSV.new(fh)
        csv << ['Deal ID', 'Deal Name', 'Deal Product', 'Product Level1', 'Product Level2', 'Budget', 'Start Date' ,'End Date']
        csv << [deal.id, deal.name, product.name, nil, nil, '100', '01/01/2018', '01/31/2018']
        csv << [nil, 'any deal', 'invalid row', nil, nil, '100', '01/01/2018', '01/31/2018']
      ensure
        fh.close()
      end
    end
  end
end
