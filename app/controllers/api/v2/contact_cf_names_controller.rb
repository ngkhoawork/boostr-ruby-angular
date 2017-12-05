class Api::V2::ContactCfNamesController < ApiController
  respond_to :json

  def index
    render json: contact_cf_names
  end

  private

  def contact_cf_names
    current_user.company.contact_cf_names.includes(:contact_cf_options)
  end
end
