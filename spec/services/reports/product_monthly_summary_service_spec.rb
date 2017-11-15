require 'rails_helper'

describe Report::ProductMonthlySummaryService do
  before do
    create_values
    create :deal_member, deal: deal
    create :deal_product_budget, deal_product: deal_product
  end

  it 'product monthly summary service with default params' do
    expect(product_monthly_summary_service(company, {}).perform[:data]).to_not be_nil
  end

  it 'product monthly summary find by product' do
    product_params = { product_id: product.id }
    expect(product_monthly_summary_service(company, product_params).perform[:data].object).to_not be_empty
  end

  it 'product monthly summary find by seller' do
    seller_params = { seller_id: deal.deal_members.first.user_id }
    expect(product_monthly_summary_service(company, seller_params).perform[:data].object).to_not be_empty
  end

  it 'product monthly summary find by created date' do
    date_params = {
      created_date_start: deal.created_at - 1.day,
      created_date_end: deal.created_at + 1.day
    }

    expect(product_monthly_summary_service(company, date_params).perform[:data].object).to_not be_empty
  end

  private

  def product_monthly_summary_service(company, params)
    @product_monthly_summary_service ||= described_class.new(company, params)
  end

  def discuss_stage
    @_discuss_stage ||= create :discuss_stage
  end

  def company
    @_company ||= create :company
  end

  def options
    @_option ||= create :option, company: company, field: field
  end

  def field
    @_field ||= create :field, company: company
  end

  def create_values
    create :value, company: company, field: field, subject: deal, option: options
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, product: product
  end

  def product
    @_product ||= create :product, company: company
  end

  def close_stage
    @_close_stage ||= create :closed_won_stage
  end
end