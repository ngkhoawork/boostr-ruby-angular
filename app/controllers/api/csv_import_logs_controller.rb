class Api::CsvImportLogsController < ApplicationController
  def index
    render json: CsvImportLog.for_company(current_user.company_id).by_source(params[:source])
  end
end
