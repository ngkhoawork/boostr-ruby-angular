require 'rails_helper'

RSpec.describe Csv::IoContentFee do
  describe '#perform' do 
    context 'without duplicated data' do
      it 'creates new content fee product budget' do
        expect{csv_io_content_fee.perform}.to change{ContentFeeProductBudget.count}.by(3)
      end
    end

    context 'with existing data' do
      it 'updates only budget' do
        content_fee_product_budget
        expect{csv_io_content_fee.perform}.to change{content_fee_product_budget.reload.budget}.from(0).to(100)
        expect{csv_io_content_fee.perform}.not_to change(ContentFeeProductBudget, :count)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def io
    @_io ||= create :io, company: company, start_date: '01/01/2018', end_date: '31/03/2018'
  end

  def product
    @_product ||= create :product, company: company
  end

  def content_fee
    @_content_fee ||= create :content_fee, io: io, product: product, budget: 0
  end

  def content_fee_product_budget
    @_content_fee_product_budget ||= content_fee.content_fee_product_budgets.first
  end

  def csv_io_content_fee
    @_csv_io_content_fee ||= build :csv_io_content_fee, company: company, io: io, product: product, start_date: '01/01/2018', end_date: '01/31/2018', budget: 100
  end
end

RSpec.describe Csv::IoContentFee, 'validations' do
  it { should validate_presence_of(:io_number) }
  it { should validate_presence_of(:product_name) }
  it { should validate_presence_of(:budget) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:end_date) }
  it { should validate_presence_of(:company_id) }
  it { should validate_numericality_of(:budget)}

  it 'validates product existence' do
    csv_io_content_fee = build :csv_io_content_fee, io: io, product_name: 'invalid name', company: company
    expect(csv_io_content_fee).not_to be_valid
    expect(csv_io_content_fee.errors.full_messages).to include('Product with --invalid name-- name doesn\'t exist')
  end

  it 'validates io existence' do
    csv_io_content_fee = build :csv_io_content_fee, io_number: '123', product: product, company: company
    expect(csv_io_content_fee).not_to be_valid
    expect(csv_io_content_fee.errors.full_messages).to include('IO with --123-- number doesn\'t exist')
  end

  it 'validates start date format mm/dd/yyyy' do
    csv_io_content_fee = build :csv_io_content_fee, start_date: '31/01/2019', io: io, product: product, company: company
    expect(csv_io_content_fee).not_to be_valid
    expect(csv_io_content_fee.errors.full_messages).to include('Start date does not match mm/dd/yyyy format')
  end

  it 'validates end date format mm/dd/yyyy' do
    csv_io_content_fee = build :csv_io_content_fee, end_date: '31/01/2019', io: io, product: product, company: company
    expect(csv_io_content_fee).not_to be_valid
    expect(csv_io_content_fee.errors.full_messages).to include('End date does not match mm/dd/yyyy format')
  end

  it 'validates end date before io end date' do
    csv_io_content_fee = build :csv_io_content_fee, end_date: '04/02/2018', io: io, product: product, company: company
    expect(csv_io_content_fee).not_to be_valid
    expect(csv_io_content_fee.errors.full_messages).to include('Monthly budget end date --04/02/2018-- is greater than IO end date')
  end

  private

  def company
    @_company ||= create :company
  end

  def io
    @_io ||= create :io, company: company, end_date: '2018-04-01'
  end

  def product
    @_product ||= create :product, company: company
  end
end
