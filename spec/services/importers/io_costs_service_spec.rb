require 'rails_helper'

describe Importers::IoCostsService do
  describe '#perform' do
    after(:each) { FileUtils.rm(file.path) if File.exist?(file.path) }
    subject { instance.perform }

    it 'creates new io cost' do
      expect{subject}.to change{Cost.count}.by(1)
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

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end

  def option
    @_option ||= create :option, name: 'test', field: field, company: company
  end

  def file
    @_file ||= Tempfile.open([Dir.tmpdir, '.csv']) do |fh|
      begin
        csv = CSV.new(fh)
        csv << ['IO Number', 'Product', 'Type', 'Month' ,'Amount']
        csv << [io.io_number, product.name, option.name, 'Jan', '100']
        csv << [io.io_number, product.name, 'test1', 'Jan', '100']
      ensure
        fh.close()
      end
    end
  end
end
