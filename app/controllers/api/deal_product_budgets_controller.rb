class Api::DealProductBudgetsController < ApplicationController
  respond_to :json

  def index
    respond_to do |format|
      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            send_data DealProductBudget.to_csv(current_user.company_id), filename: "monthly_budgets-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def create
    if params[:file].present?
      require 'timeout'
      begin
        csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        errors = DealProductBudget.import(csv_file, current_user)
        render json: errors
      rescue Timeout::Error
        return
      end
    end
  end
end
