class Api::SearchController < ApplicationController
  respond_to :json

  def all
    render json: PgSearch.multisearch(query)
                         .where(company_id: current_user.company_id)
                         .reorder(order)
                         .page(page)
                         .limit(limit)
                         .includes(:searchable),
           each_serializer: SearchSerializer
  end

  private

  def query
    params[:query]
  end

  def page
    params[:page] || 1
  end

  def limit
    params[:limit] || 20
  end

  def order
    if params[:order] == 'rank'
      'rank DESC'
    else
      'searchable_type ASC, rank DESC, id ASC'
    end
  end
end