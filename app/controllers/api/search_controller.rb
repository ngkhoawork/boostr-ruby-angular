class Api::SearchController < ApplicationController
  respond_to :json

  def all
    render json: filtered_records,
           each_serializer: SearchSerializer
  end

  private

  def filtered_records
    GlobalSearchQuery.new(options).perform
  end

  def options
    params.merge(company_id: current_user.company_id)
  end
end