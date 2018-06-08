require 'rails_helper'

RSpec.describe Csv::DealProductBudget do
  describe '#perform' do
    context 'without duplicated data' do
      it 'creates new deal product monthly budget' do
        expect{csv_deal_product_budget.perform}.to change{DealProductBudget.count}.by(3)
      end
    end

    context 'with existing data' do
      it 'updates only budget' do
        deal_product_budget
        expect{csv_deal_product_budget.perform}.to change{deal_product_budget.reload.budget}.from(0).to(100)
        expect{csv_deal_product_budget.perform}.not_to change(DealProductBudget, :count)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def deal
    @_deal ||= create :deal, company: company, start_date: '01/01/2018', end_date: '31/03/2018'
  end

  def product
    @_product ||= create :product, company: company
  end

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, product: product, budget: 0
  end

  def deal_product_budget
    @_deal_product_budget ||= deal_product.deal_product_budgets.first
  end

  def csv_deal_product_budget
    @_csv_deal_product_budget ||= build :csv_deal_product_budget, company: company, deal: deal, product: product, start_date: '01/01/2018', end_date: '01/31/2018', budget: 100
  end
end

RSpec.describe Csv::DealProductBudget, 'validations' do
  it { should validate_presence_of(:deal_name) }
  it { should validate_presence_of(:product_name) }
  it { should validate_presence_of(:budget) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:end_date) }
  it { should validate_presence_of(:company_id) }
  it { should validate_numericality_of(:budget)}

  it 'validates product existence' do
    csv_deal_product_budget = build :csv_deal_product_budget, deal: deal, product_name: 'invalid name', company: company
    expect(csv_deal_product_budget).not_to be_valid
    expect(csv_deal_product_budget.errors.full_messages).to include('Product with --invalid name-- name doesn\'t exist')
  end

  it 'validates deal existence' do
    csv_deal_product_budget = build :csv_deal_product_budget, deal_name: '123', product: product, company: company
    expect(csv_deal_product_budget).not_to be_valid
    expect(csv_deal_product_budget.errors.full_messages).to include('Deal with ---- ID and --123-- name doesn\'t exist')
  end

  it 'validates start date format mm/dd/yyyy' do
    csv_deal_product_budget = build :csv_deal_product_budget, start_date: '31/01/2019', deal: deal, product: product, company: company
    expect(csv_deal_product_budget).not_to be_valid
    expect(csv_deal_product_budget.errors.full_messages).to include('Start date --31/01/2019-- does not match mm/dd/yyyy format')
  end

  it 'validates end date format mm/dd/yyyy' do
    csv_deal_product_budget = build :csv_deal_product_budget, end_date: '31/01/2019', deal: deal, product: product, company: company
    expect(csv_deal_product_budget).not_to be_valid
    expect(csv_deal_product_budget.errors.full_messages).to include('End date --31/01/2019-- does not match mm/dd/yyyy format')
  end

  it 'validates end date before deal end date' do
    csv_deal_product_budget = build :csv_deal_product_budget, end_date: '04/02/2018', deal: deal, product: product, company: company
    expect(csv_deal_product_budget).not_to be_valid
    expect(csv_deal_product_budget.errors.full_messages).to include('Monthly budget end date --04/02/2018-- is not in between deal start date and end date')
  end

  it 'validates start date before deal start date' do
    csv_deal_product_budget = build :csv_deal_product_budget, start_date: '01/01/2016', deal: deal, product: product, company: company
    expect(csv_deal_product_budget).not_to be_valid
    expect(csv_deal_product_budget.errors.full_messages).to include('Monthly budget start date --01/01/2016-- is not in between deal start date and end date')
  end

  it 'validates start date before end date' do
    csv_deal_product_budget = build :csv_deal_product_budget, start_date: '01/01/2018', end_date: '01/01/2017', deal: deal, product: product, company: company
    expect(csv_deal_product_budget).not_to be_valid
    expect(csv_deal_product_budget.errors.full_messages).to include('Start date --01/01/2018-- is greater than end date --01/01/2017--')
  end

  private

  def company
    @_company ||= create :company
  end

  def deal
    @_deal ||= create :deal, company: company, start_date: '2018-01-01', end_date: '2018-04-01'
  end

  def product
    @_product ||= create :product, company: company
  end
end
