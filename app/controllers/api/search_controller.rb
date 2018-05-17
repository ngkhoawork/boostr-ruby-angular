class Api::SearchController < ApplicationController
  respond_to :json

  def all
    render json: PgSearch.multisearch(query)
                         .where(company_id: current_user.company_id)
                         .reorder('searchable_type ASC, rank DESC, id ASC')
                         .page(params[:page] || 1)
                         .per(20)
                         .includes(:searchable),
           each_serializer: SearchSerializer
  end

  private

  def query
    params[:query]
  end
end