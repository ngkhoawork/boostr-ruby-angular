require 'rails_helper'

describe Report::PipelineSummaryService do
  before do
    deal
    create_values
    create :deal_member, deal: deal
  end

  it 'pipeline summary service with default params' do
    expect(pipeline_summary_service(company, {}).perform).to_not be_nil
  end

  it 'pipeline summary service with wrong params' do
    closed_date_params = {
      closed_date_start: Date.today.to_formatted_s(:iso8601),
      closed_date_end: Date.tomorrow.to_formatted_s(:iso8601)
    }

    expect(pipeline_summary_service(company, closed_date_params).perform.object.to_a).to be_empty
  end

  it 'pipeline summary by source and type' do
    source_and_type = {
      source_id: options.id,
      type_id: options.id
    }

    expect(pipeline_summary_service(company, source_and_type).perform.object.to_a).to_not be_empty
  end

  it 'pipeline summary by type' do
    source = { type_id: options.id }
    expect(pipeline_summary_service(company, source).perform.object.to_a).to_not be_empty
  end

  it 'pipeline summary find by stage' do
    expect(pipeline_summary_service(company, {stage_ids: [deal.stage_id]}).perform.object).to be_exist
  end

  it 'pipeline summary find by seller' do
    seller_params = { seller_id: deal.deal_members.first.user_id }

    expect(pipeline_summary_service(company, seller_params).perform.object).to be_exist
  end

  it 'pipeline summary find by start date' do
    date_params = {
      start_date: deal.start_date - 1.day,
      end_date: deal.end_date - 1.day
    }

    expect(pipeline_summary_service(company, date_params).perform.object).to be_exist
  end

  it 'pipeline summary find by created date' do
    date_params = {
      created_date_start: deal.created_at - 1.day,
      created_date_end: deal.created_at + 1.day
    }

    expect(pipeline_summary_service(company, date_params).perform.object).to be_exist
  end

  private

  def pipeline_summary_service(company, params)
    @pipeline_summary_service ||= described_class.new(company, params)
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
    @_values = create :value, company: company, field: field, subject: deal, option: options
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def close_stage
    @_close_stage ||= create :closed_won_stage
  end
end