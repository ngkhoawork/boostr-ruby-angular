class Api::CsvImportLogsController < ApplicationController
  include CleanPagination

  def index
    max_per_page = 50

    paginate import_logs.count, max_per_page do |limit, offset|
      render json: import_logs.limit(limit).offset(offset)
    end
  end

  private

  def import_logs
    CsvImportLog.for_company(current_user.company_id).by_source(params[:source])
  end
end
