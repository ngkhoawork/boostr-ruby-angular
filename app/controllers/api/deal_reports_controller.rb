class Api::DealReportsController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json {
        render json: generate_data_report.to_json
      }
      format.csv {
        send_data generate_csv_report, filename: "deals-report-#{1.week.ago}.csv"
      }
    end
  end


  private

  def deal_report_service
    @deal_report_service ||= DealReportService.new(target_date: 1.week.ago)
  end

  def generate_csv_report
    deal_report_service.generate_csv_report
  end

  def generate_data_report
    deal_report_service.generate_report
  end

end