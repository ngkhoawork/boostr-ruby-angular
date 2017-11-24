class Api::PublishersController < ApplicationController
  respond_to :json

  def index
    render json: paginate(filtered_publishers),
           each_serializer: Api::Publishers::IndexSerializer
  end

  def create
    if build_resource.save
      render json: Api::PublisherSerializer.new(resource), status: :created
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if resource.update(publisher_params)
      render json: Api::PublisherSerializer.new(resource)
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def settings
    render json: Api::PublisherSettingsSerializer.new(current_user.company)
  end

  private

  def resource
    @resource ||= Publisher.find(params[:id])
  end

  def build_resource
    @resource = Publisher.new(publisher_params)
  end

  def filtered_publishers
    PublishersQuery.new(filter_params).perform
  end

  def filter_params
    params
      .permit(:q, :comscore, :publisher_stage_id, :type_id, :my_publishers_bool, :my_team_publishers_bool)
      .merge(current_user: current_user, company_id: current_user.company_id)
  end

  def publisher_params
    params.require(:publisher).permit(
      :name,
      :comscore,
      :website,
      :estimated_monthly_impressions,
      :actual_monthly_impressions,
      :client_id,
      :publisher_stage_id,
      :type_id,
      address_attributes: [
        :id,
        :country,
        :street1,
        :street2,
        :city,
        :state,
        :zip,
        :phone,
        :mobile,
        :email
      ],
      publisher_custom_field_attributes: [
        :id,
        :company_id,
        :deal_id,
        :currency1,
        :currency2,
        :currency3,
        :currency4,
        :currency5,
        :currency6,
        :currency7,
        :currency_code1,
        :currency_code2,
        :currency_code3,
        :currency_code4,
        :currency_code5,
        :currency_code6,
        :currency_code7,
        :text1,
        :text2,
        :text3,
        :text4,
        :text5,
        :note1,
        :note2,
        :datetime1,
        :datetime2,
        :datetime3,
        :datetime4,
        :datetime5,
        :datetime6,
        :datetime7,
        :number1,
        :number2,
        :number3,
        :number4,
        :number5,
        :number6,
        :number7,
        :integer1,
        :integer2,
        :integer3,
        :integer4,
        :integer5,
        :integer6,
        :integer7,
        :boolean1,
        :boolean2,
        :boolean3,
        :percentage1,
        :percentage2,
        :percentage3,
        :percentage4,
        :percentage5,
        :dropdown1,
        :dropdown2,
        :dropdown3,
        :dropdown4,
        :dropdown5,
        :dropdown6,
        :dropdown7,
        :number_4_dec1,
        :number_4_dec2,
        :number_4_dec3,
        :number_4_dec4,
        :number_4_dec5,
        :number_4_dec6,
        :number_4_dec7
      ]
    ).merge(company_id: current_user.company_id)
  end
end
