require 'rails_helper'

describe Report::ProductMonthlySummarySerializer do
  before do
    create :billing_address_validation, company: company
    create :billing_deal_contact, deal: deal, contact: contact
    deal_product_cf_name
    deal_product_cf
    deal_product_budget
  end

  it 'product monthly summary serialized data' do
    expect(product_monthly_summary.advertiser.symbolize_keys).to eq(id: deal.advertiser.id,
                                                             name: deal.advertiser.name)
    expect(product_monthly_summary.agency.symbolize_keys).to eq(id: deal.agency.id,
                                                         name: deal.agency.name)
    expect(product_monthly_summary.holding_company).to eq deal.agency.holding_company
    expect(product_monthly_summary.budget).to eq deal_product_budget.budget.to_i
    expect(product_monthly_summary.weighted_budget).to eq weighted_budget
    expect(product_monthly_summary.budget_loc).to eq deal_product_budget.budget_loc.to_i
    expect(product_monthly_summary.stage.symbolize_keys).to eq(name: deal.stage.name,
                                                        probability: deal.stage.probability)
    expect(product_monthly_summary.type).to be_nil
    expect(product_monthly_summary.source).to be_nil
    expect(product_monthly_summary.custom_fields[deal_product_cf_name.field_name]).to eq(deal_product.deal_product_cf.text1)
    expect(product_monthly_summary.members[0].symbolize_keys).to eq(id: deal_member.user.id,
                                                             name: deal_member.user.name,
                                                             share: deal_member.share)
  end

  private

  def product_monthly_summary
    described_class.new(deal_product_budget, deal_custom_fields: custom_fields, deal_product_cf_names: company.deal_product_cf_names)
  end

  def deal
    @_deal ||= create :deal, company: company, deal_members: [deal_member]
  end

  def deal_member
    @_member ||= create :deal_member
  end

  def company
    @_company ||= create :company
  end

  def custom_fields
    @_deal_custom_field ||= company.fields.where(subject_type: 'DealProuduct').pluck(:id, :name)
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

  def deal_product
    @_deal_product ||= create :deal_product, deal: deal, product: product
  end

  def deal_product_budget
    @_deal_product_budget ||= create :deal_product_budget, deal_product: deal_product
  end

  def product
    @_product ||= create :product, company: company
  end

  def address
    @_address ||= create :address, country: 'United Kingdom'
  end

  def deal_product_cf_name
    @_deal_product_cf_name ||= create :deal_product_cf_name, company: company
  end

  def deal_product_cf
    @_deal_product_cf ||= create :deal_product_cf, company: company, deal_product: deal_product, text1: 'test'
  end

  def weighted_budget
    deal_product_budget.budget.to_f * deal.stage.probability.to_f / 100
  end
end