class Api::ReportsController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json { render json: activity_summary_user_service.perform }
      format.csv { send_data activity_summary_user_csv_report, filename: "reports-#{Date.today}.csv" }
    end
  end

  def summary_by_account
    respond_to do |format|
      format.json { render json: activity_summary_account_service.perform }
      format.csv { send_data activity_summary_account_csv_report, filename: "reports-by-account-#{Date.today}.csv" }
    end
  end

  private

  def activity_summary_user_service
    ActivitySummary::UserService.new(current_user, params: params)
  end

  def activity_summary_account_service
    ActivitySummary::AccountService.new(current_user, params: params) 
  end

  def activity_summary_user_csv_report
    Csv::ActivitySummaryService.new(
      all_team_sales_reps,
      activity_summary_user_csv_options
    ).perform
  end

  def activity_summary_user_csv_options
    {
      company: company,
      start_date: start_date,
      end_date: end_date
    }
  end

  def activity_summary_account_csv_report

  end
end
