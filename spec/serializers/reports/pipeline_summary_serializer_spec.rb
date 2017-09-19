require 'rails_helper'

describe Report::PipelineSummarySerializer do
  before do
    create :billing_deal_contact, deal: deal, contact: contact
    create :deal_custom_field_name, company: company
  end

  it 'pipeline summary serialized data' do
    expect(pipeline_summary.advertiser).to eq("id" => deal.advertiser.id, "name" => deal.advertiser.name)
    expect(pipeline_summary.category).to eq deal.advertiser.client_category
    expect(pipeline_summary.agency).to eq("id" => deal.agency.id, "name" => deal.agency.name)
    expect(pipeline_summary.holding_company).to eq deal.agency.holding_company
    expect(pipeline_summary.budget).to eq deal.budget.to_i
    expect(pipeline_summary.budget_loc).to eq deal.budget_loc.to_i
    expect(pipeline_summary.stage).to eq("name" => deal.stage.name, "probability" => deal.stage.probability)
    expect(pipeline_summary.initiative).to eq deal.initiative
    expect(pipeline_summary.billing_contact).to eq(
                                                    "id" => deal.billing_contact.id,
                                                    "name" => deal.billing_contact.name,
                                                    "email" => deal.billing_contact.email)
    expect(pipeline_summary.team).to be_nil
    expect(pipeline_summary.members).to eq(deal.deal_members.to_a)
    expect(pipeline_summary.send(:company)).to eq(company)
    expect(pipeline_summary.closed_reason).to be_nil
    expect(pipeline_summary.type).to be_nil
    expect(pipeline_summary.source).to be_nil
  end

  private

  def pipeline_summary
    described_class.new(deal, deal_custom_fields: custom_fields)
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def company
    @_company ||= create :company
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
    create :address, country: 'United Kingdom'
  end
end