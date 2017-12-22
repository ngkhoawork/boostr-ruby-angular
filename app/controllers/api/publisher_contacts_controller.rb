class Api::PublisherContactsController < ApplicationController
  respond_to :json

  def create
    contact = company.contacts.new(contact_params)

    if contact.save
      render json: contact, status: :created
    else
      render json: { errors: contact.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if contact.update(contact_params)
      render json: contact
    else
      render json: { errors: contact.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    contact.update(publisher_id: nil)

    render nothing: true
  end

  private

  def publisher
    company.publishers.find(params[:publisher_id])
  end

  def contact
    company.contacts.find(params[:id])
  end

  def company
    @_company ||= current_user.company
  end

  def contact_params
    params.require(:contact).permit(
      :name,
      :position,
      :note,
      :publisher_id,
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
      values_attributes: [
        :id,
        :field_id,
        :option_id,
        :value
      ],
      contact_cf_attributes: [
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
    ).merge(created_by: current_user.id)
  end
end
