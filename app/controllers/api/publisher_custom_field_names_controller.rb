class Api::PublisherCustomFieldNamesController < ApplicationController
  respond_to :json

  def index
    render json: publisher_custom_field_names.order_by_position
  end

  def create
    publisher_custom_field_name = publisher_custom_field_names.new(publisher_custom_field_name_params)

    if publisher_custom_field_name.save
      render json: publisher_custom_field_name, status: :created
    else
      render json: { errors: publisher_custom_field_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if publisher_custom_field_name.update_attributes(publisher_custom_field_name_params)
      render json: publisher_custom_field_name, status: :accepted
    else
      render json: { errors: publisher_custom_field_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    publisher_custom_field_name.destroy

    render nothing: true
  end

  private

  def publisher_custom_field_names
    company
      .publisher_custom_field_names
      .includes(:publisher_custom_field_options)
  end

  def publisher_custom_field_name
    company.publisher_custom_field_names.find(params[:id])
  end

  def company
    current_user.company
  end

  def publisher_custom_field_name_params
    params
      .require(:publisher_custom_field_name)
      .permit(
        :field_type, :field_label, :is_required, :position, :show_on_modal, :disabled, 
        { contact_cf_options_attributes: [:id, :value] }
      )
  end
end
