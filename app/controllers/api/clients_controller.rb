class Api::ClientsController < ApplicationController
  include CleanPagination
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json {
        if params[:name].present?
           results = suggest_clients
        else
          results = clients
                      .by_type_id(params[:client_type_id])
                      .by_category(params[:client_category_id])
                      .by_region(params[:client_region_id])
                      .by_segment(params[:client_segment_id])
                      .by_city(params[:city])
                      .by_last_touch(params[:start_date], params[:end_date])
                      .by_name(params[:search])
                      .order(:name)
                      .preload(:address, :client_member_info, :latest_advertiser_activity, :latest_agency_activity)
                      .distinct
        end

        if params[:owner_id]
          client_ids = Client.joins("INNER JOIN client_members ON clients.id = client_members.client_id").where("clients.company_id = ? AND client_members.user_id = ?", company.id, params[:owner_id]).pluck(:client_id)
          results = results.by_ids(client_ids)
        end

        response.headers['X-Total-Count'] = results.count.to_s
        results = results.limit(limit).offset(offset)
        render json: results,
          each_serializer: Clients::ClientListSerializer,
            advertiser: Client.advertiser_type_id(company),
            agency: Client.agency_type_id(company),
            categories: category_options
      }

      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            send_data company.clients.to_csv(company), filename: "clients-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def search_clients
    render json: suggest_clients
                  .order(:name)
                  .pluck_to_struct(:id, :name, :client_type_id)
  end

  def fuzzy_search
    clients = company.clients.fuzzy_search(params[:search])
    render json: clients
  end

  def filter_options
    client_ids = clients.pluck(:id)

    user_ids = ClientMember.where("client_id in (?)", client_ids).pluck(:user_id)
    owners = User.where("id in (?)", user_ids).pluck_to_struct(:id, :first_name, :last_name).collect { |user| {id: user.id, name: user.first_name + " " + user.last_name} }

    cities = Address.where("addressable_id in (?) and addressable_type='Client'", client_ids).pluck(:city).uniq.reject(&:blank?)

    render json: {owners: owners, cities: cities}
  end

  def show
    render json: client
  end

  def create
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'Client',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: { message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)" }, status: :ok
    else
      client = company.clients.new(client_params)
      client.created_by = current_user.id
      if client.save
        render json: client, status: :created
      else
        render json: { errors: client.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    if client.update_attributes(client_params)
      render json: client, status: :accepted
    else
      render json: { errors: client.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    errors = []
    if client.agency_deals.count > 0 || client.advertiser_deals.count > 0
      errors << 'Deal'
    end
    if client.agency_activities.count > 0 || client.activities.count > 0
      errors << 'Activity'
    end
    if client.contacts.count > 0 || client.primary_contacts.count > 0 || client.secondary_contacts.count > 0
      errors << 'Contact'
    end
    if client.agency_ios.count > 0 || client.advertiser_ios.count > 0
      errors << 'IO'
    end
    if client.bp_estimates.count > 0
      errors << 'Business Plan'
    end
    if client.child_clients.count > 0
      errors << 'Account'
    end
    if client.advertisers.count > 0
      errors << 'Agency'
    end
    if client.agencies.count > 0 
      errors << 'Advertiser'
    end

    if errors.count > 0
      render json: { error: "This account is used on #{errors.join(', ')}. Remove all references to this record before deleting." }, status: :unprocessable_entity
    else
      client.destroy
      render nothing: true
    end
  end

  def sellers
    client = company.clients.find(params[:client_id])
    if client.present?
      render json: company.users.by_name(params[:name]).limit(10)
    else
      render json: "Client not found", status: :not_found
    end
  end

  def stats
    client = company.clients.find(params[:client_id])
    if client.present?
      deals = company.deals.active.for_client(params[:client_id])
      total_count = deals.count
      won_deal_count = deals.won.count
      lost_deal_count = deals.lost.count
      agency_type_id = Client.agency_type_id(company)
      advertiser_type_id = Client.advertiser_type_id(company)
      interaction_count = 0
      if client.client_type_id == agency_type_id
        interaction_count = client.agency_activities.count
      elsif client.client_type_id == advertiser_type_id
        interaction_count = client.activities.count
      end
      render json: {
                     won: won_deal_count,
                     lost: lost_deal_count,
                     open: (total_count - won_deal_count - lost_deal_count),
                     interaction: interaction_count
             }
    else
      render json: "Client not found", status: :not_found
    end
  end

  def connected_contacts
    client = company.clients.find(params[:client_id])
    if client && client.client_type
      if client.client_type.name == "Agency"
        contacts = client.advertiser_contacts
      elsif client.client_type.name == "Advertiser"
        contacts = client.agency_contacts
      end
      if params[:name]
        contacts = contacts.where('contacts.name ilike ?', "%#{params[:name]}%")
      end
      if params[:page] && params[:per]
        contacts = contacts.limit(limit).offset(offset)
      end
      render json: contacts
    else
      render json: []
    end
  end

  def connected_client_contacts
    max_per_page = 10

    paginate connected_client_contacts_relation.count, max_per_page do |limit, offset|
      render json: connected_client_contacts_relation.limit(limit).offset(offset),
             each_serializer: ClientContacts::ConnectedClientContactsSerializer
    end
  end

  def child_clients
    client = company.clients.find(params[:client_id])
    if client
      render json: client.child_clients
    else
      render json: []
    end
  end

  private

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end

  def client_params
    params.require(:client).permit(
      :name, :website, :note, :client_type_id, :client_category_id, :client_subcategory_id, :parent_client_id, :client_region_id, :client_segment_id, :holding_company_id,
      { 
        address_attributes: [:country, :street1, :street2, :city, :state, :zip, :phone, :email],
        values_attributes: [:id, :field_id, :option_id, :value],
        account_cf_attributes: [
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
      }
    )
  end

  def client
    @client ||= company.clients.where(id: params[:id]).first!
  end

  def clients
    if params[:filter] == 'company' && current_user.leader?
      company.clients
    elsif params[:filter] == 'team'
      if team.present?
        team.clients
      else
        company.clients
      end
    elsif params[:filter] == 'all'
      company.clients
    else
      current_user.clients
    end
  end

  def client_record
    @_client_record ||= company.clients.find(params[:client_id])
  end

  def company
    @company ||= current_user.company
  end

  def team
    if current_user.leader?
      company.teams.where(leader: current_user).first!
    else
      current_user.team
    end
  end

  def suggest_clients
    return @suggest_clients if @suggest_clients

    @suggest_clients = company.clients.by_name_and_type_with_limit(params[:name], params[:client_type_id])

    if params[:assoc] && client
      @suggest_clients = @suggest_clients.excepting_client_associations(client, params[:assoc])
    end

    @suggest_clients
  end

  def connected_client_contacts_relation
    clcons ||= related_client_contact_relation
      .where(primary: false)
      .joins(:client, :contact)
      .preload(:client, contact: [:address, :primary_client])
      .order('clients.name')
  end

  def related_client_contact_relation
    if client_record.client_type.present? && client_record.client_type.name == 'Advertiser'
      related_agency_client_contacts
    else
      related_advertiser_client_contacts
    end
  end

  def related_agency_client_contacts
    ClientContact.where(client_id: client_record.id)
  end

  def related_advertiser_client_contacts
    ClientContact
      .where('contact_id in (?)', client_record.primary_contacts.ids)
      .where('client_contacts.client_id in (?)', client_record.advertisers.ids)
  end

  def company_job_level_options
    current_user.company.fields.find_by(subject_type: 'Contact', name: 'Job Level').options.select(:id, :field_id, :name)
  end

  def category_options
    company.fields.client_category_fields.to_options
  end
end
