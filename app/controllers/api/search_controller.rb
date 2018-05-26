class Api::SearchController < ApplicationController
  respond_to :json

  def all
    render json: filtered_records,
           each_serializer: SearchSerializer
  end

  def count
    render json: { count: filtered_count }
  end

  private

  def filtered_count
    PgSearch.multisearch(options[:query])
            .where(company_id: options[:company_id])
            .count
  end

  def filtered_records
    GlobalSearchQuery.new(options).perform
  end

  def options
    params.merge(company_id: current_user.company_id)
  end
end