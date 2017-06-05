class Api::RequestsController < ApplicationController
  include CleanPagination
  respond_to :json

  def index
    max_per_page = 20
    paginate requests.count, max_per_page do |limit, offset|
      render json: requests
      .preload(:deal, :requester, :assignee, :requestable)
      .limit(limit).offset(offset), each_serializer: Requests::RequestSerializer
    end
  end

  def show
    render json: request_item, serializer: Requests::RequestSerializer
  end

  def create
    request = deal.requests.new(request_params)
    request.requester = current_user
    request.company_id = current_user.company_id

    if request.save
      render json: request, status: :created
    else
      render json: { errors: request.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if request_item.update_attributes(request_params)
      render json: request_item, status: :accepted
    else
      render json: { errors: request_item.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def request_params
    params.require(:request).permit(
      :id,
      :deal_id,
      :description,
      :resolution,
      :due_date,
      :status,
      :assignee_id,
      :requestable_id,
      :requestable_type,
      :request_type
    )
  end

  def requests
    Request.where(company_id: current_user.company_id).by_request_type(type_filter).by_status(status_filter)
  end

  def type_filter
    params[:request_type]
  end

  def status_filter
    params[:status]
  end

  def deal
    @_deal ||= Deal.find_by(
      id: request_params['deal_id'],
      company_id: current_user.company_id
    )
  end

  def request_item
    @_request_item ||= Request.find_by(
      id: params['id'], company_id: current_user.company_id
    )
  end
end
