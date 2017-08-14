class Api::DealReportsController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json {
        render json: { report_data: generate_data_report }.to_json
      }
      format.csv {
        send_data generate_csv_report, filename: "deals-report-#{1.week.ago}.csv"
      }
    end
  end

  private

  def deal_report_service
    @deal_report_service ||= DealReportService.new(params: date_range_params, company_id: current_user.company_id)
  end

  def generate_csv_report
    deal_report_service.generate_csv_report
  end

  def generate_data_report
    report_data = deal_report_service.generate_report
    reports_with_type = report_data.each {|key, val| val.each{|deal| deal['deal_type'] = key.to_s.humanize } }
    reports_with_type.flatten(2).keep_if { |elem| elem.kind_of? Hash }
  end

  def date_range_params
    params.permit(:start_date, :end_date, :change_type)
  end
end
