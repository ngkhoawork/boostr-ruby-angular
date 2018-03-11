require 'rails_helper'

describe Csv::PipelineSummaryReportService do
  before { User.current = create :user }

  it "pipeline service report" do
    expect(pipeline_summary_service).to_not be_nil
  end

  private

  def pipeline_summary_serializer
    date_params = {
        start_date: deal.start_date - 1.day,
        end_date: deal.end_date - 1.day
    }

    @_pipeline_summary ||= Report::PipelineSummaryService.new(company, date_params).perform
  end

  def pipeline_summary_service
    @_pipeline_summary_service ||= described_class.new(company, pipeline_summary_serializer.as_json).perform
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