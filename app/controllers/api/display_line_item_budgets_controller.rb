class Api::DisplayLineItemBudgetsController < ApplicationController
  respond_to :json

  def create
    if params[:file].present?
      require 'timeout'
      begin
        csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        errors = DisplayLineItemBudget.import(csv_file, current_user)
        render json: errors
      rescue Timeout::Error
        return
      end
    end
  end
end
