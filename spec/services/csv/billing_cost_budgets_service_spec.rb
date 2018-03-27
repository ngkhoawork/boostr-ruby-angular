require 'rails_helper'

describe Csv::BillingCostBudgetsService do
  subject(:csv_report) { described_class.new(company, cost.cost_monthly_amounts).perform }

  before do
    account_manager
    account_manager2
    seller
  end

  it { is_expected.to_not be_nil }

  it 'includes headers' do
    expect(csv_report).to match "IO Number,Name,Advertiser,Agency,Seller,Account Manager," +
                                "Product,Amount,Cost Type,Actualization Status"
  end

  it 'includes io cost records' do
    expect(csv_report).to match "888,#{io.name},#{io.advertiser&.name},#{io.agency&.name}," +
                                "nik andreev,mary manager;yujun zhang,display,100.0,option1,Pending"
  end

  private

  def company
    @_company ||= create :company
  end

  def account_manager
    @_account_manager_user ||= create :user, user_type: ACCOUNT_MANAGER, first_name: 'mary', last_name: 'manager'
    @_account_manager ||= create :io_member, io: io, user: @_account_manager_user, share: 30
  end

  def account_manager2
    @_account_manager_user2 ||= create :user, user_type: ACCOUNT_MANAGER, first_name: 'yujun', last_name: 'zhang'
    @_account_manager2 ||= create :io_member, io: io, user: @_account_manager_user2, share: 20
  end

  def seller
    @_seller_user ||= create :user, user_type: SELLER, first_name: 'nik', last_name: 'andreev'
    @_seller ||= create :io_member, io: io, user: @_seller_user, share: 50
  end

  def io
    @_io ||= create :io, company: company, start_date: '01/01/2018', end_date: '31/01/2018',
                         io_number: '888', name: 'test-io'
  end

  def cost
    @_cost ||= create :cost, io: io, product: product, budget_loc: 100, budget: 100
    @_cost.tap do |cost|
      cost.values.find_or_create_by(field: field, option: option)
    end
  end

  def option
    @_option ||= field.options.create(name: 'option1', company: company)
  end

  def field
    @_field ||= company.fields.find_or_create_by(
      subject_type: 'Cost',
      name: 'Cost Type',
      value_type: 'Option',
      locked: true
    )
  end

  def cost_monthly_amount
    cost.cost_monthly_amounts.first
  end

  def product
    @_product ||= create :product, company: company, name: 'display'
  end
end
