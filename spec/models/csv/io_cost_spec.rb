require 'rails_helper'

RSpec.describe Csv::IoCost do
  describe '#perform' do 
    subject { csv_io_cost.perform }

    context 'without duplicated data' do
      it 'creates new io cost' do
        expect{subject}.to change{Cost.count}.by(1)
      end

      it 'creates new io cost monthly amount' do
        expect{subject}.to change{CostMonthlyAmount.count}.by(3)
        expect(cost_monthly_amount).not_to be_nil
        expect(cost_monthly_amount.budget).to eq(100)
        expect(cost_monthly_amount.budget_loc).to eq(100)
      end
    end

    context 'with existing data' do
      before do
        csv_io_cost(cost.id)
      end

      it 'updates amount' do
        expect{subject}.to change{cost_monthly_amount.reload.budget_loc}.from(0).to(100)
      end

      it 'updates is_estimated' do
        expect{subject}.to change{cost.reload.is_estimated}.from(true).to(false)
      end

      it 'updates existing record' do
        expect{subject}.not_to change(CostMonthlyAmount, :count)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def io
    @_io ||= create :io, company: company, start_date: '10/01/2018', end_date: '10/03/2018'
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
    @_cost ||= create :cost, io: io, product: product, budget: 0, budget_loc: 0, is_estimated: true
  end

  def cost_monthly_amount
    @_cost_monthly_amount ||= io.costs.first.cost_monthly_amounts.find_by(start_date: Date.new(2018,01,10), end_date: Date.new(2018,01,31))
  end

  def csv_io_cost(cost_id=nil)
    @_csv_io_cost ||= build :csv_io_cost, company: company, io: io, product_name: product.name, amount: 100, month: '01/01/2018', type: option.name, cost_id: cost_id, imported_costs: cost_id.nil? ? [] : [cost]
  end
end

RSpec.describe Csv::IoCost, 'validations' do
  it { should validate_presence_of(:io_number) }
  it { should validate_presence_of(:product_name) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:month) }
  it { should validate_presence_of(:company_id) }
  it { should validate_numericality_of(:amount)}

  it 'validates product existence' do
    csv_io_cost = build :csv_io_cost, io: io, product_name: 'invalid name', company: company
    expect(csv_io_cost).not_to be_valid
    expect(csv_io_cost.errors.full_messages).to include('Product with --invalid name-- name doesn\'t exist')
  end

  it 'validates io existence' do
    csv_io_cost = build :csv_io_cost, io_number: '123', product_name: product.name, company: company
    expect(csv_io_cost).not_to be_valid
    expect(csv_io_cost.errors.full_messages).to include('IO with --123-- number doesn\'t exist')
  end

  it 'validates type existence' do
    csv_io_cost = build :csv_io_cost, io: io, product_name: product.name, company: company, type: 'invalid'
    expect(csv_io_cost).not_to be_valid
    expect(csv_io_cost.errors.full_messages).to include('Cost type with --invalid-- doesn\'t exist')
  end

  it 'validates month format mm/dd/yyyy' do
    csv_io_cost = build :csv_io_cost, io: io, product_name: product.name, company: company, month: '2018/01'
    expect(csv_io_cost).not_to be_valid
    expect(csv_io_cost.errors.full_messages).to include('Month --2018/01-- does not match mm/dd/yyyy format')
  end

  private

  def company
    @_company ||= create :company
  end

  def io
    @_io ||= create :io, company: company
  end

  def product
    @_product ||= create :product, company: company
  end
end
