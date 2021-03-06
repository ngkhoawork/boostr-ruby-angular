class Api::BpsController < ApplicationController
  respond_to :json

  def index
    if bps_settings?
      render json: bps.order('created_at DESC').map{ |bp| bp.as_json }
    else
      render json: bps.active.map{ |bp| bp.as_json }
    end
  end

  def show
    if bp.present?
      render json: bp, status: :ok
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  def create
    bp = company.bps.new(bp_params)
    if bp.save

      render json: bp.as_json, status: :created
    else
      render json: { errors: bp.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if bp.update_attributes(bp_params)
      render json: bp.as_json
    else
      render json: { errors: bp.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if bp.destroy
      render json: bp.as_json
    else
      render json: { errors: bp.errors.messages }, status: :unprocessable_entity
    end
  end

  def add_client
    bp = bps.find(params[:bp_id])
    if bp.present?
      client = company.clients.find(params[:client_id])
      if client.users.count > 0
        client.users.each do |user|
          bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: params[:client_id], user_id: user.id)
          bp_estimate.save()
        end
      else
        bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: client.id, user_id: nil)
        bp_estimate.save()
      end

      render json: bp, status: :ok
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  def assign_client
    bp = bps.find(params[:bp_id])
    if bp.present?
      client = company.clients.find(params[:client_id])
      bp_estimates = bp.bp_estimates.where(client_id: client.id)
      if bp_estimates.count == 0
        bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: params[:client_id], user_id: current_user.id)
        bp_estimate.save()
        # if client.users.count > 0
        #   client.users.each do |user|
        #     bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: params[:client_id], user_id: user.id)
        #     bp_estimate.save()
        #   end
        # else
        #   bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: client.id, user_id: nil)
        #   bp_estimate.save()
        # end
      else
        bp_estimates.each do |bp_estimate|
          if bp_estimate.user_id == nil || bp_estimate.user_id == current_user.id
            bp_estimate.user_id = current_user.id
            bp_estimate.save()
            break
          end
        end
      end

      render json: bp, status: :ok
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  def add_all_clients
    bp = bps.find(params[:bp_id])
    if bp.present?
      advertiser_id = Client.advertiser_type_id(bp.company)
      client_ids = bp.bp_estimates.collect{ |item| item.client_id}

      clients = company.clients.by_type_id(advertiser_id).by_name(params[:name]).where("id NOT IN (?)", client_ids).limit(10)

      clients.each do |client|
        if client.users.count > 0
          client.users.each do |user|
            bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: client.id, user_id: user.id)
            bp_estimate.save()
          end
        else
          bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: client.id, user_id: nil)
          bp_estimate.save()
        end

      end

      render json: bp, status: :ok
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  def assign_all_clients
    bp = bps.find(params[:bp_id])
    if bp.present?
      advertiser_id = Client.advertiser_type_id(bp.company)
      client_ids = bp.bp_estimates.where("bp_estimates.user_id IS NOT NULL").collect{ |item| item.client_id}

      clients = company.clients.by_type_id(advertiser_id).by_name(params[:name]).where("id NOT IN (?)", client_ids).limit(10)

      clients.each do |client|
        bp_estimates = bp.bp_estimates.where(client_id: client.id)
        if bp_estimates.count == 0
          bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: client.id, user_id: current_user.id)
          bp_estimate.save()
          # if client.users.count > 0
          #   client.users.each do |user|
          #     bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: client.id, user_id: user.id)
          #     bp_estimate.save()
          #   end
          # else
          #   bp_estimate = BpEstimate.find_or_initialize_by(bp_id: bp.id, client_id: client.id, user_id: nil)
          #   bp_estimate.save()
          # end
        else
          bp_estimates.each do |bp_estimate|
            if bp_estimate.user_id == nil || bp_estimate.user_id == current_user.id
              bp_estimate.user_id = current_user.id
              bp_estimate.save()
              break
            end
          end
        end
      end

      render json: bp, status: :ok
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  def unassigned_clients
    bp = bps.find(params[:bp_id])
    if bp.present?
      advertiser_id = Client.advertiser_type_id(bp.company)
      client_ids = []
      if params[:all] && params[:all] == 'true'
        client_ids = bp.bp_estimates.where("bp_estimates.user_id IS NOT NULL").collect{ |item| item.client_id}
      else
        client_ids = bp.bp_estimates.collect{ |item| item.client_id}
      end
      clients = company.clients.by_type_id(advertiser_id).by_name(params[:name]).where("id NOT IN (?)", client_ids).limit(10)
      render json: clients, status: :ok
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  def account_total_estimates
    bp = bps.find(params[:bp_id])
    if bp.present?
      data = bp.bp_estimates
      .joins("LEFT JOIN clients ON clients.id = bp_estimates.client_id")
      .where("bp_estimates.client_id IS NOT NULL and user_id in (?)", member_ids)
      .group("clients.id")
      .select("clients.id AS client_id, COALESCE( SUM(bp_estimates.estimate_seller), 0 ) AS total_estimate_seller, COALESCE( SUM(bp_estimates.estimate_mgr), 0 ) AS total_estimate_mgr, clients.name")
      .collect { |bp_estimate| {client_id: bp_estimate.client_id, name: (bp_estimate.client_id.present? ? bp_estimate.name : ""), total_estimate_seller: bp_estimate.total_estimate_seller, total_estimate_mgr: bp_estimate.total_estimate_mgr} }
      render json: data
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  def seller_total_estimates
    bp = bps.find(params[:bp_id])
    if bp.present?
      data = bp.bp_estimates
      .joins("LEFT JOIN users ON users.id = bp_estimates.user_id")
      .where("bp_estimates.user_id IS NOT NULL and users.user_type in (1, 2)")
      .group("users.id")
      .select("users.id AS user_id, COALESCE( SUM(bp_estimates.estimate_seller), 0 ) AS total_estimate_seller, COALESCE( SUM(bp_estimates.estimate_mgr), 0 ) AS total_estimate_mgr, users.first_name, users.last_name")
      .collect { |bp_estimate| {user_id: bp_estimate.user_id, name: (bp_estimate.user_id.present? ? (bp_estimate.first_name + ' ' + bp_estimate.last_name) : ""), total_estimate_seller: bp_estimate.total_estimate_seller, total_estimate_mgr: bp_estimate.total_estimate_mgr} }
      render json: data
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  private

  def bps_settings?
    params[:settings]
  end

  def bp_params
    params.require(:bp).permit(:name, :time_period_id, :due_date, :read_only, :active)
  end

  def company
    current_user.company
  end

  def member_ids
    return @member_ids if defined?(@member_ids)
    member_ids = []
    case params[:filter]
      when 'my'
        member_ids << current_user.id
      when 'team'
        member_ids = current_user.all_team_members.collect{ |member| member.id }
        member_ids << current_user.id
      else
        member_ids = current_user.company.users.collect{ |member| member.id }
    end

    @member_ids = member_ids
  end

  def bps
    company.bps
  end

  def bp
    @bp ||= bps.find(params[:id])
  end
end
