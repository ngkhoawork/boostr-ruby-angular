class Api::DealCustomFieldNamesController < ApplicationController
  respond_to :json

  def index
    render json: deal_custom_field_names.order("position asc")
  end

  def show
    render json: deal_custom_field_name
  end

  def update
    if deal_custom_field_name.update_attributes(deal_custom_field_name_params)
      render json: deal_custom_field_name, status: :accepted
    else
      render json: { errors: deal_custom_field_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    index_arr = deal_custom_field_names.by_type(deal_custom_field_name_params[:field_type]).collect{ |item| item.field_index }
    field_index = 0

    field_limit = DealCustomFieldName.get_field_limit(deal_custom_field_name_params[:field_type])
    for i in 1..field_limit
      if index_arr.index(i).nil?
        field_index = i
        break
      end
    end
    if field_index == 0
      render json: { errors: {"This field type" => [" reached limit."]} }, status: :unprocessable_entity
      return
    end
    deal_custom_field_name = deal_custom_field_names.new(deal_custom_field_name_params)
    deal_custom_field_name.field_index = field_index

    if deal_custom_field_name.save
      render json: deal_custom_field_name, status: :created
    else
      render json: { errors: deal_custom_field_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    deal_custom_field_name.destroy
    render nothing: true
  end

  private

  def deal_custom_field_name
    @deal_custom_field_name ||= company.deal_custom_field_names.find(params[:id])
  end

  def deal_custom_field_name_params
    params.require(:deal_custom_field_name).permit(:field_type, :field_label, :is_required, :position, :show_on_modal)
  end

  def deal_custom_field_names
    @deal_custom_field_names ||= company.deal_custom_field_names
  end

  def company
    @company ||= current_user.company
  end
end
