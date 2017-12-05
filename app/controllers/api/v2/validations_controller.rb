class Api::V2::ValidationsController < ApiController
  respond_to :json

  def account_base_fields
    render json: account_base_fields_json
  end

  def deal_base_fields
    render json: deal_base_fields_json
  end

  private

  def company
    @company ||= current_user.company
  end

  def account_base_fields_json
    company.validations.account_base_fields.preload(:criterion).group_by(&:object)
  end

  def deal_base_fields_json
    company.validations.deal_base_fields.preload(:criterion)
  end
end
