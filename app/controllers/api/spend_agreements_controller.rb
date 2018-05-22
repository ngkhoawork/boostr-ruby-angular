class Api::SpendAgreementsController < ApplicationController
  respond_to :json

  def index
    render json: by_pages(filtered_spend_agreements),
           each_serializer: Api::SpendAgreements::ListSerializer,
           advertiser_type_id: Client.advertiser_type_id(company),
           agency_type_id: Client.agency_type_id(company),
           type_field_id: company.fields.find_by(subject_type: 'Multiple', name: 'Spend Agreement Type').id,
           status_field_id: company.fields.find_by(subject_type: 'Multiple', name: 'Spend Agreement Status').id
  end

  def show
    render json: spend_agreement,
           serializer: Api::SpendAgreements::SingleSerializer,
           advertiser_type_id: Client.advertiser_type_id(company),
           agency_type_id: Client.agency_type_id(company)
  end

  def create
    spend_agreement = company.spend_agreements.new(spend_agreement_params)

    if spend_agreement.save!
      render json: spend_agreement, serializer: Api::SpendAgreements::SingleSerializer, status: :created
    else
      render json: spend_agreement.errors, status: :unprocessable_entity
    end
  end

  def update
    if spend_agreement.update(spend_agreement_params)
      render json: spend_agreement, serializer: Api::SpendAgreements::SingleSerializer, status: :ok
    else
      render json: spend_agreement.errors, status: :unprocessable_entity
    end
  end

  def destroy
    spend_agreement.destroy

    render nothing: true, status: :no_content
  end

  private

  def filtered_spend_agreements
    SpendAgreementsQuery.new(filter_params).perform
  end

  def spend_agreements
    @_spend_agreements ||= company.spend_agreements
  end

  def spend_agreement
    @_spend_agreement ||= spend_agreements.find(params[:id])
  end

  def company
    @_company ||= current_user.company
  end

  def filter_params
    params
      .permit(*filter_param_keys)
      .merge(current_user: current_user, company_id: current_user.company_id)
  end

  def filter_param_keys
    [
      :q,
      :my_records,
      :my_teams_records,
      :manually_tracked,
      :min_target,
      :max_target,
      :start_date,
      :end_date,
      :type_id,
      :status_id,
      { by_client_ids: [] }
    ]
  end

  def spend_agreement_params
    params.require(:spend_agreement).permit(
      :name,
      :start_date,
      :end_date,
      :target,
      :manually_tracked,
      :holding_company_id,
      { client_ids: [] },
      { parent_companies_ids: [] },
      { publishers_ids: [] },
      {
        values_attributes: [
          :id,
          :field_id,
          :option_id,
          :value
        ],

        deal_custom_field_attributes: deal_custom_field_attributes,
        spend_agreement_team_members_attributes: tm_attributes,
        spend_agreement_deals_attributes: deals_attributes
      }
    )
  end

  def deal_custom_field_attributes
    [
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
      :sum1,
      :sum2,
      :sum3,
      :sum4,
      :sum5,
      :sum6,
      :sum7,
      :number_4_dec1,
      :number_4_dec2,
      :number_4_dec3,
      :number_4_dec4,
      :number_4_dec5,
      :number_4_dec6,
      :number_4_dec7,
      :link1,
      :link2,
      :link3,
      :link4,
      :link5,
      :link6,
      :link7
    ]
  end

  def tm_attributes
    [:id, :spend_agreement_id, :user_id]
  end

  def deals_attributes
    [:id, :spend_agreement_id, :deal_id]
  end
end
