require 'rails_helper'

describe Csv::ProductMonthlySummaryDecorator do
  before do
    deal_product_cf_name
    deal_product_cf
  end

  it 'decorate product monthly summary successfully and return expected values' do
    expect(product_monthly_summary_decorator.record_type).to eq 'Deal'
    expect(product_monthly_summary_decorator.record_id).to eq deal.id
    expect(product_monthly_summary_decorator.name).to eq deal.name
    expect(product_monthly_summary_decorator.advertiser).to eq deal.advertiser.name
    expect(product_monthly_summary_decorator.agency).to eq deal.agency.name
    expect(product_monthly_summary_decorator.holding_company).to eq deal.agency.holding_company
    expect(product_monthly_summary_decorator.budget_usd).to eq budget_usd
    expect(product_monthly_summary_decorator.budget).to eq deal_product_budget.budget_loc.to_i
    expect(product_monthly_summary_decorator.weighted_amt).to eq weighted_amt
    expect(product_monthly_summary_decorator.%).to eq deal.stage.probability
    expect(product_monthly_summary_decorator.start_date).to eq parse_time(deal_product_budget.start_date)
    expect(product_monthly_summary_decorator.end_date).to eq parse_time(deal_product_budget.end_date)
    expect(product_monthly_summary_decorator.created_date).to eq parse_time(deal.created_at)
    expect(product_monthly_summary_decorator.closed_date).to eq parse_time(deal.closed_at)
    expect(product_monthly_summary_decorator.deal_type).to be_nil
    expect(product_monthly_summary_decorator.deal_source).to be_nil
    expect(product_monthly_summary_decorator.stage).to eq deal.stage.name
    expect(product_monthly_summary_decorator.method_missing("not_correct_name")).to be_nil
    expect(product_monthly_summary_decorator.team_member).to eq "#{deal_member.user.name} #{deal_member.share}%"
  end

  private

  def product_monthly_summary_serializer
    @_product_monthly_summary ||= Report::ProductMonthlySummarySerializer.new(deal_product_budget, deal_custom_fields: custom_fields, deal_product_cf_names: company.deal_product_cf_names)
  end

  def product_monthly_summary_decorator
    @_product_monthly_summary_decorator ||= described_class.new(product_monthly_summary_serializer.as_json, company, company.deal_product_cf_names)
  end

  def deal
    @_deal ||= create :deal, deal_members: [deal_member]
  end

  def company
    @_company ||= create :company
  end

  def deal_member
    @_member ||= create :deal_member
  end

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, product: product
  end

  def deal_product_budget
    @_deal_product_budget ||= create :deal_product_budget, deal_product: deal_product
  end

  def product
    @_product ||= create :product, company: company
  end

  def custom_fields
    @_deal_custom_field ||= company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end

  def advertiser
    @_advertiser ||= create :client, company: company, address: address
  end

  def contact
    @_contact ||= create :contact,
                         clients: [advertiser],
                         company: company,
                         address: address
  end

  def address
    @_address = create :address, country: 'United Kingdom'
  end

  def deal_product_cf_name
    @_deal_product_cf_name ||= create :deal_product_cf_name, company: company
  end

  def deal_product_cf
    @_deal_product_cf ||= create :deal_product_cf, company: company, deal_product: deal_product, text1: 'test'
  end

  def budget_usd
    format_currency(deal_product_budget.budget)
  end

  def weighted_amt
    format_currency(deal_product_budget.budget.to_f * deal.stage.probability.to_f / 100)
  end

  def format_currency(budget)
    ActiveSupport::NumberHelper.number_to_currency(budget, precision: 0)
  end

  def parse_time(time)
    (time ? time.strftime('%m/%d/%Y') : '')
  end
end