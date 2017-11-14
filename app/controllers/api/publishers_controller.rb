class Api::PublishersController < ApplicationController
  respond_to :json

  def index
    render json: filtered_publishers.page(page).per(per_page),
           each_serializer: Api::PublisherSerializer
  end

  private

  def filtered_publishers
    PublishersQuery.new(filter_params).perform
  end

  def filter_params
    params
      .permit(:q, :stage_id, :type_option_id, :my_publishers_bool, :my_team_publishers_bool)
      .merge(current_user: current_user, company_id: current_user.company_id)
  end

  def page
    params[:page] || 0
  end

  def per_page
    params[:per_page] || 50
  end
end
