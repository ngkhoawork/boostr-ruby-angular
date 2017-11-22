require 'rails_helper'

describe Csv::ProductMonthlySummaryService do
  it "pipeline service report" do
    expect(product_monthly_summary_service).to_not be_nil
  end

  private

  def product_monthly_summary_serializer
    date_params = {
        start_date: deal.start_date - 1.day,
        end_date: deal.end_date - 1.day
    }

    @_product_monthly_summary ||= Report::ProductMonthlySummaryService.new(company, date_params).perform
  end

  def product_monthly_summary_service
    @_product_monthly_summary_service ||= described_class.new(company, product_monthly_summary_serializer.as_json).perform
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