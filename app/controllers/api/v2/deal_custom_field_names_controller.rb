class Api::V2::DealCustomFieldNamesController < ApiController
  respond_to :json

  def index
    render json: deal_custom_field_names.order("position asc").as_json({
        include: {
            deal_custom_field_options: {
                only: [:id, :value]
            }
        }
    })
  end

  private

  def deal_custom_field_names
    @deal_custom_field_names ||= company.deal_custom_field_names
  end

  def company
    @company ||= current_user.company
  end
end
