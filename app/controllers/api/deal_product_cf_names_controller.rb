class Api::DealProductCfNamesController < ApplicationController
  respond_to :json

  def index
    render json: deal_product_cf_names.order(:position).includes(:deal_product_cf_options).as_json({include: {
        deal_product_cf_options: {
          only: [:id, :value]
        }
      }
    })
  end

  def show
    render json: deal_product_cf_name
  end

  def update
    if !deal_product_cf_name_params[:deal_product_cf_options_attributes].nil? && deal_product_cf_name_params[:deal_product_cf_options_attributes].count > 0
      option_ids = deal_product_cf_name_params[:deal_product_cf_options_attributes].map{ |option| option[:id] }
      deal_product_cf_name.deal_product_cf_options.where('id NOT IN (?)', option_ids).destroy_all
    else
      deal_product_cf_name.deal_product_cf_options.destroy_all
    end

    if deal_product_cf_name.update_attributes(deal_product_cf_name_params)
      render json: deal_product_cf_name, status: :accepted
    else
      render json: { errors: deal_product_cf_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    index_arr = deal_product_cf_names.by_type(deal_product_cf_name_params[:field_type]).collect{ |item| item.field_index }
    field_index = 0

    field_limit = DealProductCfName.get_field_limit(deal_product_cf_name_params[:field_type])
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
    deal_product_cf_name = deal_product_cf_names.new(deal_product_cf_name_params)
    deal_product_cf_name.field_index = field_index

    if deal_product_cf_name_params[:field_type] == 'sum'
      deal_custom_field_name = deal_custom_field_names.new(deal_product_cf_name_params)
      deal_custom_field_name.field_index = field_index
      deal_custom_field_name.save
    end

    if deal_product_cf_name.save
      render json: deal_product_cf_name, status: :created
    else
      render json: { errors: deal_product_cf_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if deal_product_cf_name.field_type == 'sum'
      deal_custom_field_names.by_type('sum').by_index(deal_product_cf_name.field_index).destroy_all
    end

    deal_product_cf_name.destroy

    render nothing: true
  end

  def csv_headers
    render json: deal_product_cf_names.order("position asc"), each_serializer: CsvHeaderSerializer
  end

  private

  def deal_product_cf_name
    @deal_product_cf_name ||= company.deal_product_cf_names.find(params[:id])
  end

  def deal_product_cf_name_params
    params.require(:deal_product_cf_name).permit(
        :field_type, :field_label, :is_required, :position, :show_on_modal, :disabled,
        {
            deal_product_cf_options_attributes: [:id, :value]
        }
    )
  end

  def deal_product_cf_names
    @deal_product_cf_names ||= company.deal_product_cf_names
  end

  def deal_custom_field_names
    @deal_custom_field_names ||= company.deal_custom_field_names
  end

  def company
    @company ||= current_user.company
  end
end
