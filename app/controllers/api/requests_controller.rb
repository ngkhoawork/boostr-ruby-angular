class Api::RequestsController < ApplicationController
  respond_to :json

  def create
    request = deal.requests.new(request_params)
    request.requester = current_user

    if request.save
      render json: request, status: :created
    else
      render json: { errors: request.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if request.update_attributes(request_params)
      render json: request, status: :accepted
    else
      render json: { errors: request.errors.messages }, status: :unprocessable_entity
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
      :requestable_type
    )
  end

  def deal
    @_deal ||= Deal.find_by(
      id: request_params['deal_id'],
      company_id: current_user.company_id
    )
  end
end
