class Api::ReportsController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json { 
        render json: reports
      }
      format.csv { 
        send_data ordered_reports.to_csv, filename: "reports-#{Date.today}.csv" 
      }
    end
  end

  private

  def report
    @report ||= company.reports.find(params[:id])
  end

  def reports
    company.reports
  end

  def company
    @company ||= current_user.company
  end

  def ordered_reports
    company.reports.order(:time_period_id, :user_id, :name, :value)
  end
end
