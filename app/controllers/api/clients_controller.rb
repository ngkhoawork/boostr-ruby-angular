class Api::ClientsController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json {
        if params[:name].present?
          results = suggest_clients
        elsif params[:activity].present?
          results = activity_clients
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
                      .includes(:address)
                      .distinct
        end
        if params[:owner_id]
          client_ids = Client.joins("INNER JOIN client_members ON clients.id = client_members.client_id").where("clients.company_id = ? AND client_members.user_id = ?", company.id, params[:owner_id]).pluck(:client_id)
          results = results.by_ids(client_ids)
        end

        response.headers['X-Total-Count'] = results.count.to_s
        results = results.limit(limit).offset(offset)
        render json: results.as_json
      }

      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            if current_user.leader?
              ordered_clients = company.clients
            elsif team.present?
              ordered_clients = team.clients
            else
              ordered_clients = current_user.clients
            end
            send_data ordered_clients.to_csv(current_user.company), filename: "clients-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def filter_options
    client_ids = clients.select("id").collect { |client_row| client_row.id }

    user_ids = ClientMember.where("client_id in (?)", client_ids).select("user_id").collect { |client_member| client_member.user_id }
    owners = User.where("id in (?)", user_ids).select("id, first_name, last_name").collect { |user| {id: user.id, name: user.first_name + " " + user.last_name} }

    cities = Address.where("addressable_id in (?) and addressable_type='Client'", client_ids).pluck(:city).uniq.reject { |c| c.nil? || c.blank? }

    render json: {owners: owners, cities: cities}
  end

  def show
    render json: client
  end

  def create
    if params[:file].present?
      require 'timeout'
      begin
        status = Timeout::timeout(120) {
          csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
          clients = Client.import(csv_file, current_user)
          render json: clients
        }
      rescue Timeout::Error
        return
      end
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
    client.destroy
    render nothing: true
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
        render json: client.agency_contacts
      elsif client.client_type.name == "Advertiser"
        render json: client.advertiser_contacts
      end
    else
      render json: []
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
      :name, :website, :client_type_id, :client_category_id, :client_subcategory_id, :parent_client_id, :client_region_id, :client_segment_id,
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
      }
    )
  end

  def client
    @client ||= company.clients.where(id: params[:id]).first!
  end

  def clients
    if params[:filter] == 'company' && current_user.leader?
      company.clients
    elsif params[:filter] == 'team' && team.present?
      team.clients
    elsif params[:filter] == 'all'
      # TODO eventually we may want to limit this... it is only used in the new deal dropdown
      company.clients
    else
      current_user.clients
    end
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
    @_suggest_clients ||= company.clients.by_name_and_type_with_limit(params[:name], params[:client_type_id])
  end

  def activity_clients
    @_activity_clients ||= company.clients.where.not(activity_updated_at: nil).order(activity_updated_at: :desc).limit(10)
  end
end
