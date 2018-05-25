class Api::SpendAgreementPublishersController < ApplicationController
  respond_to :json

  def index
    render json: spend_agreement_publishers
  end

  def create
    spend_agreement_publisher = spend_agreement_publishers.build(spend_agreement_publisher_params)

    if spend_agreement_publisher.save
      render json: spend_agreement_publisher, status: :created
    else
      render json: { errors: spend_agreement_publisher.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    spend_agreement_publisher.destroy
    render json: true
  end

  private

  def spend_agreement_publisher_params
    params.require(:spend_agreement_publisher).permit(:id, :publisher_id, :spend_agreement_id)
  end

  def company
    current_user.company
  end

  def spend_agreement
    company.spend_agreements.find(params[:spend_agreement_id])
  end

  def spend_agreement_publisher
    spend_agreement_publishers.find(params[:id])
  end

  def spend_agreement_publishers
    spend_agreement.spend_agreement_publishers
  end
end
