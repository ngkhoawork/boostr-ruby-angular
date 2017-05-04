class Api::ContactCfNamesController < ApplicationController
  respond_to :json

  def index
    render json: contact_cf_names
  end

  def show
    render json: contact_cf_name
  end

  def update
    if contact_cf_name.update_attributes(contact_cf_name_params)
      render json: contact_cf_name, status: :accepted
    else
      render json: { errors: contact_cf_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    contact_cf_name = contact_cf_names.new(contact_cf_name_params)

    if contact_cf_name.save
      render json: contact_cf_name, status: :created
    else
      render json: { errors: contact_cf_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    contact_cf_name.destroy

    render nothing: true
  end

  private

  def contact_cf_names
    current_user.company.contact_cf_names.includes(:contact_cf_options)
  end

  def contact_cf_name
    current_user.company.contact_cf_names.find(params[:id])
  end

  def contact_cf_name_params
    params.require(:contact_cf_name).permit(
      :field_type, :field_label, :is_required, :position, :show_on_modal, :disabled,
      {
        contact_cf_options_attributes: [:id, :value]
      }
    )
  end
end
