class Api::FilterQueriesController < ApplicationController
  def index
    render json: filter_queries
  end

  def create
    filter_query = company.filter_queries.new(filter_query_params.merge(user: current_user))

    if filter_query.save
      update_default_value(filter_query)

      render json: filter_query, status: :created
    else
      render json: { errors: filter_query.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if filter_query.update(filter_query_params)
      update_default_value(filter_query)

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

  def update_default_value(filter_query)
    company
      .filter_queries
      .by_user(current_user.id)
      .by_query_type(filter_query.query_type)
      .all_without_specific_record(filter_query.id)
      .default
      .update_all(default: false)
  end
end
