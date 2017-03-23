class Api::CsvImportLogsController < ApplicationController
  def index
    render json: CsvImportLog.where(company_id: current_user.company_id)
  end
end
