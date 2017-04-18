class Api::V1::ClientsController < ApiController
  respond_to :json

  def index
    if params[:name].present?
      results = suggest_clients
    elsif params[:activity].present?
      results = activity_clients
    else
      results = clients
                  .by_type_id(params[:client_type_id])
                  .order(:name)
                  .distinct
    end

    response.headers['X-Total-Count'] = results.count.to_s
    results = results.limit(limit).offset(offset)
    render json: results,
      each_serializer: Api::V1::ClientListSerializer,
        advertiser: Client.advertiser_type_id(company),
        agency: Client.agency_type_id(company)
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

  private

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end

  def client_params
    params.require(:client).permit(
      :name, :website, :client_type_id, :client_category_id, :client_subcategory_id, :parent_client_id,
      { 
        address_attributes: [:country, :street1, :street2, :city, :state, :zip, :phone, :email],
        values_attributes: [:id, :field_id, :option_id, :value]
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
    return @search_clients if defined?(@search_clients)

    @search_clients = company.clients
                        .where('name ilike ?', "%#{params[:name]}%")
                        .by_type_id(params[:client_type_id])
                        .limit(10)
  end

  def activity_clients
    return @activity_clients if defined?(@activity_clients)

    @activity_clients = company.clients.where.not(activity_updated_at: nil).order(activity_updated_at: :desc).limit(10)
  end
end
