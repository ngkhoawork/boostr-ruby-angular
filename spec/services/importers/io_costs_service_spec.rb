require 'rails_helper'

describe Importers::IoCostsService do
  describe '#perform' do
    after(:each) { FileUtils.rm(file.path) if File.exist?(file.path) }
    subject { instance.perform }

    before do
      cost
    end

    it 'creates new cost' do
      expect{subject}.to change{Cost.count}.by(1)
    end

    it 'creates new cost monthly amounts' do
      expect{subject}.to change{CostMonthlyAmount.count}.by(3)
    end

    it 'updates existing cost budgets' do
      expect{subject}.to change{cost.reload.budget}.to(150)
    end

    it 'updates new cost budgets' do
      expect{subject}.to change{Cost.last.budget}.to(450)
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
    @_io ||= create :io, company: company, io_number: 1000, start_date: '2018-01-10', end_date: '2018-03-31', budget: 0
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

  def option2
    @_option2 ||= create :option, name: 'test2', field: field, company: company
  end

  def cost
    @_cost ||= create :cost, io: io, product: product, budget: 0, budget_loc: 0, is_estimated: true
  end

  def file
    @_file ||= Tempfile.open([Dir.tmpdir, '.csv']) do |fh|
      begin
        csv = CSV.new(fh)
        csv << ['IO Number', 'Cost ID', 'Product Name', 'Type', 'Month' ,'Amount']
        csv << [io.io_number, cost.id, product.name, option.name, '01/01/2018', '100']
        csv << [io.io_number, cost.id, product.name, option.name, '03/01/2018', '50']
        csv << [io.io_number, nil, product.name, option2.name, '01/01/2018', '50']
        csv << [io.io_number, nil, product.name, option2.name, '02/01/2018', '150']
        csv << [io.io_number, nil, product.name, option2.name, '03/01/2018', '250']
        csv << [io.io_number, nil, product.name, 'test1', '02/01/2018', '100']
      ensure
        fh.close()
      end
    end
  end
end
