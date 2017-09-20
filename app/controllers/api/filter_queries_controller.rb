class Api::FilterQueriesController < ApplicationController
  def index
    render json: filter_queries
  end

  def create
    filter_query = company.filter_queries.new(filter_query_params.merge(user: current_user))

    if filter_query.save
      render json: filter_query, status: :created
    else
      render json: { errors: filter_query.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    filter_query.assign_attributes(filter_query_params)

    if filter_query.save
      render json: filter_query
    else
      render json: { errors: filter_query.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    filter_query.destroy

    render nothing: true
  end

  private

  def company
    @_company ||= current_user.company
  end

  def filter_query_params
    params.require(:filter_query).permit(:name, :query_type, :global, :default, :filter_params)
  end

  def filter_queries
    company
      .filter_queries
      .by_user_and_global(current_user.id)
      .by_query_type(params[:query_type])
  end

  def filter_query
    @_filter_query ||= company.filter_queries.find(params[:id])
  end
end
