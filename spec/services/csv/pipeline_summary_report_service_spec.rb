require 'rails_helper'

describe Csv::PipelineSummaryReportService do
  it "pipeline service report" do
    expect(pipeline_summary_service).to_not be_nil
  end

  private

  def pipeline_summary_serializer
    @_pipeline_summary ||= Report::PipelineSummarySerializer.new(deal, deal_custom_fields: custom_fields)
  end

  def pipeline_summary_service
    @_pipeline_summary_service ||= described_class.new(company, pipeline_summary_serializer.as_json)
  end

  def company
    @_company ||= create :company
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def custom_fields
    @_deal_custom_field ||= company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end
end