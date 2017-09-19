require 'rails_helper'

describe Report::PipelineSummaryService do
  before do
    field = create :field, company: company
    deal = create :deal, company: company
    @option = create :option, company: company, field: field
    
    create :value, company: company, field: field, subject: deal, option: @option
  end

  it "pipeline summary service" do
    expect(default_pipeline_summary_service.send(:deals)).to be_exist
    expect(default_pipeline_summary_service.send(:deal_custom_fields).flatten).to include "Close Reason"
    expect(default_pipeline_summary_service.send(:deals_with_source_and_type)).to be_empty

    expect(pipeline_summary_with_wrong_params.send(:deals)).to be_empty
    expect(pipeline_summary_with_wrong_params.send(:data_for_serializer)).to be_empty
    expect(pipeline_summary_with_wrong_params.send(:deals_with_source_and_type)).to be_empty


    expect(pipeline_summary_by_source_and_type.send(:deals_with_source_and_type)).to_not be_empty
    expect(pipeline_summary_by_source_and_type.send(:data_for_serializer)).to_not be_empty
    expect(pipeline_summary_by_source_and_type.send(:deals)).to_not be_empty
  end

  private

  def default_pipeline_summary_service
    @pipeline_summary_service ||= described_class.new(company, {})
  end

  def pipeline_summary_with_wrong_params
    @_pipeline_summary ||= described_class.new(company, {
      closed_date_start: Date.today.to_formatted_s(:iso8601),
      closed_date_end: Date.tomorrow.to_formatted_s(:iso8601)
    })
  end

  def pipeline_summary_by_source_and_type
    @_pipeline_summary_by_source_and_type ||= described_class.new(company, {source_id: @option.id, type_id: @option.id})
  end

  def company
    @_company ||= create :company
  end
end