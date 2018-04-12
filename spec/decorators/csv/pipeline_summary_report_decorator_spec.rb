require 'rails_helper'

describe Csv::PipelineSummaryReportDecorator do
  let!(:company) { create :company }

  before do
    create :billing_address_validation, company: company
    create :billing_deal_contact, deal: deal, contact: contact
  end

  it 'decorate pipeline summary successfully and return expected values' do
    expect(pipeline_summary_decorator.deal_id).to eq deal.id
    expect(pipeline_summary_decorator.name).to eq deal.name
    expect(pipeline_summary_decorator.budget_usd).to eq deal.budget
    expect(pipeline_summary_decorator.advertiser).to eq deal.advertiser.name
    expect(pipeline_summary_decorator.category).to eq deal.advertiser.client_category
    expect(pipeline_summary_decorator.agency).to eq deal.agency.name
    expect(pipeline_summary_decorator.holding_company).to eq deal.agency.holding_company
    expect(pipeline_summary_decorator.budget_usd).to eq deal.budget
    expect(pipeline_summary_decorator.budget).to eq deal.budget_loc
    expect(pipeline_summary_decorator.%).to eq deal.stage.probability
    expect(pipeline_summary_decorator.start_date).to eq deal.start_date
    expect(pipeline_summary_decorator.end_date).to eq deal.end_date
    expect(pipeline_summary_decorator.created_date).to eq deal.created_at
    expect(pipeline_summary_decorator.closed_date).to eq deal.closed_at
    expect(pipeline_summary_decorator.close_reason).to be_nil
    expect(pipeline_summary_decorator.close_comments).to be_nil
    expect(pipeline_summary_decorator.team).to be_nil
    expect(pipeline_summary_decorator.type).to be_nil
    expect(pipeline_summary_decorator.source).to be_nil
    expect(pipeline_summary_decorator.initiative).to be_nil
    expect(pipeline_summary_decorator.billing_contact).to eq "#{deal.billing_contact.name}/#{deal.billing_contact.email}"
    expect(pipeline_summary_decorator.stage).to eq deal.stage.name
    expect(pipeline_summary_decorator.method_missing("not_correct_name")).to be_nil
    expect(pipeline_summary_decorator.members).to eq "#{deal_member.user.name} #{deal_member.share}%"
  end

  private

  def pipeline_summary_serializer
    @_pipeline_summary ||= Report::PipelineSummarySerializer.new(deal, deal_custom_fields: custom_fields)
  end

  def pipeline_summary_decorator
    @_pipeline_summary_decorator ||= described_class.new(pipeline_summary_serializer.as_json, company)
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
end