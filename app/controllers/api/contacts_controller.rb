class Api::ContactsController < ApplicationController
  respond_to :json

  def index
    results = contacts_search_service.perform

    respond_to do |format|
      format.json {

        response.headers['X-Total-Count'] = results.total_count
        render json: results.includes(:primary_client).preload(
          :latest_happened_activity,
          :client,
          :values,
          :address,
          non_primary_client_contacts: [:client]
        )
        .limit(limit)
        .offset(offset), each_serializer: ContactSerializer,
                         contact_options: company_job_level_options,
                         advertiser: advertiser_type_id,
                         agency: Client.agency_type_id(current_user.company)
      }

      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            send_data Csv::ContactsService.new(current_user.company, results).perform, filename: "contacts-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def show
    render json: contact, serializer: Api::ContactDetailSerializer,
                          contact_options: company_job_level_options,
                          advertiser: advertiser_type_id,
                          agency: Client.agency_type_id(current_user.company)
  end

  def create
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'Contact',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    else
      if contact_params[:client_id].present?
        contact = current_user.company.contacts.new(contact_params)
        contact.created_by = current_user.id

        if contact.save
          render json: contact, status: :created
        else
          render json: { errors: contact.errors.messages }, status: :unprocessable_entity
        end
      else
        render json: { errors: { "primary account": ["can't be blank"] } }, status: :unprocessable_entity
      end
    end
  end

  def update
    if contact_params[:client_id].present? || params[:unassign] == true
      if contact.update_attributes(contact_params)
        contact.update_primary_client if params[:contact][:set_primary_client]

        render json: contact, serializer: ContactUpdateSerializer, status: :accepted
      else
        render json: { errors: contact.errors.messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: { "primary account": ["can't be blank"] } }, status: :unprocessable_entity
    end

  end

  def destroy
    contact.destroy

    render nothing: true
  end

  def metadata
    render json: Contact.metadata(current_user.company_id)
  end

  def related_clients
    render json: contact.non_primary_client_contacts.joins(:client).where('clients.client_type_id = ?', advertiser_type_id)
    .preload(client: [:address])
    .as_json(
      include: {
        client: {
          include: {
            address: { only: :city }
          }
        }
      }
    )
  end

  def advertisers
    render json: current_user.company.clients.by_type_id(advertiser_type_id)
                                     .by_name(params[:name])
                                     .without_related_clients(params[:id])
                                     .limit(limit)
                                     .as_json(override: true, only: [:id, :name])
  end

  def assign_account
    client_contact = contact.client_contacts.new(client_id: params[:client_id], primary: false)

    if client_contact.save
      render nothing: true
    else
      render json: { errors: client_contact.errors.messages }, status: :unprocessable_entity
    end
  end

  def unassign_account
    client_contact = contact.client_contacts.find_by(client_id: params[:client_id])

    client_contact.destroy
    render nothing: true
  end

  private

  def contact_params
    params.require(:contact).permit(
      :name,
      :position,
      :note,
      :client_id,
      :lead_id,
      :web_lead,
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
        :currency8,
        :currency9,
        :currency10,
        :currency_code1,
        :currency_code2,
        :currency_code3,
        :currency_code4,
        :currency_code5,
        :currency_code6,
        :currency_code7,
        :currency_code8,
        :currency_code9,
        :currency_code10,
        :text1,
        :text2,
        :text3,
        :text4,
        :text5,
        :text6,
        :text7,
        :text8,
        :text9,
        :text10,
        :note1,
        :note2,
        :note3,
        :note4,
        :note5,
        :note6,
        :note7,
        :note8,
        :note9,
        :note10,
        :datetime1,
        :datetime2,
        :datetime3,
        :datetime4,
        :datetime5,
        :datetime6,
        :datetime7,
        :datetime8,
        :datetime9,
        :datetime10,
        :number1,
        :number2,
        :number3,
        :number4,
        :number5,
        :number6,
        :number7,
        :number8,
        :number9,
        :number10,
        :integer1,
        :integer2,
        :integer3,
        :integer4,
        :integer5,
        :integer6,
        :integer7,
        :integer8,
        :integer9,
        :integer10,
        :boolean1,
        :boolean2,
        :boolean3,
        :boolean4,
        :boolean5,
        :boolean6,
        :boolean7,
        :boolean8,
        :boolean9,
        :boolean10,
        :percentage1,
        :percentage2,
        :percentage3,
        :percentage4,
        :percentage5,
        :percentage6,
        :percentage7,
        :percentage8,
        :percentage9,
        :percentage10,
        :dropdown1,
        :dropdown2,
        :dropdown3,
        :dropdown4,
        :dropdown5,
        :dropdown6,
        :dropdown7,
        :dropdown8,
        :dropdown9,
        :dropdown10,
        :number_4_dec1,
        :number_4_dec2,
        :number_4_dec3,
        :number_4_dec4,
        :number_4_dec5,
        :number_4_dec6,
        :number_4_dec7,
        :number_4_dec8,
        :number_4_dec9,
        :number_4_dec10
      ]
    )
  end

  def contact
    @contact ||= current_user.company.contacts.find(params[:id])
  end

  def limit
    params[:per].present? ? params[:per].to_i : 20
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end

  def company_job_level_options
    current_user.company.fields.find_by(subject_type: 'Contact', name: 'Job Level').options.select(:id, :field_id, :name)
  end

  def advertiser_type_id
    Client.advertiser_type_id(current_user.company)
  end

  def contacts_search_service
    @_contacts_search_service ||= ContactsSearchService.new(current_user: current_user, params: params)
  end
end
