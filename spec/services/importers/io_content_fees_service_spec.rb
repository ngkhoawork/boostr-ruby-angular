require 'rails_helper'

describe Importers::IoContentFeesService do
  describe '#perform' do
    after(:each) { FileUtils.rm(file.path) if File.exist?(file.path) }
    subject { instance.perform }

    it 'creates new content fee product budget' do
      expect{subject}.to change{ContentFeeProductBudget.count}.by(1)
    end

    it 'updates content fee budgets' do
      expect{subject}.to change{io.content_fees&.first&.budget}.to(100)
    end

    it 'updates io budgets' do
      expect{subject}.to change{io.reload.budget}.from(0).to(100)
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

  def io
    @_io ||= create :io, company: company, io_number: 1000, start_date: '2018-01-01', end_date: '2018-01-31', budget: 0
  end

  def product
    @_product ||= create :product, company: company, name: 'boostr'
  end

  def file
    @_file ||= Tempfile.open([Dir.tmpdir, '.csv']) do |fh|
      begin
        csv = CSV.new(fh)
        csv << ['IO Number', 'Product', 'Product Level1', 'Product Level2', 'Budget', 'Start Date' ,'End Date']
        csv << [io.io_number, product.name, nil, nil, '100', '01/01/2018', '01/31/2018']
        csv << [101, 'invalid row', nil, nil, '100', '01/01/2018', '01/31/2018']
      ensure
        fh.close()
      end
    end
  end
end
