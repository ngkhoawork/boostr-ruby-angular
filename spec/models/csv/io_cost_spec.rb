require 'rails_helper'

RSpec.describe Csv::IoCost do
  describe '#perform' do 
    context 'without duplicated data' do
      it 'creates new io cost' do
        expect{csv_io_cost.perform}.to change{Cost.count}.by(1)
      end
    end

    context 'with existing data' do
      before do
        cost
      end

      it 'updates amount' do
        expect{csv_io_cost.perform}.to change{cost.reload.budget_loc}.from(10).to(100)
      end

      it 'updates is_estimated' do
        expect{csv_io_cost.perform}.to change{cost.reload.is_estimated}.from(true).to(false)
      end

      it 'updates existing record' do
        expect{csv_io_cost.perform}.not_to change(Cost, :count)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def io
    @_io ||= create :io, company: company, start_date: '01/01/2018', end_date: '31/01/2018'
  end

  def product
    @_product ||= create :product, company: company
  end

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end

  def option
    @_option ||= create :option, name: 'test1', field: field, company: company
  end

  def cost
    @_cost ||= create :cost, io: io, product: product, start_date: '2018-01-01', end_date: '2018-01-31', budget: 10, budget_loc: 10, is_estimated: true
  end

  def csv_io_cost
    @_csv_io_cost ||= build :csv_io_cost, company: company, io: io, product: product, amount: 100, month: 'Jan', type: option.name 
  end
end

RSpec.describe Csv::IoCost, 'validations' do
  it { should validate_presence_of(:io_number) }
  it { should validate_presence_of(:product_name) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:month) }
  it { should validate_presence_of(:company_id) }
  it { should validate_numericality_of(:amount)}
end
