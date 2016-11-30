class Api::WhereToPitchController < ApplicationController
  respond_to :json

  def index
    render json: {
      advertisers: where_to_pitch_by_advertiser,
      agencies: where_to_pitch_by_agency
    }
  end

  private

  def where_to_pitch_by_advertiser
    clients = []
    advertisers.each do |advertiser|
      advertiser_deals = advertiser_deals_list(advertiser.id)
      next if advertiser_deals.length == 0
      complete_deals = complete_deals_list(advertiser_deals)
      incomplete_deals = incomplete_deals_list(advertiser_deals)

      win_rate = 0.0
      win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0

      total_deals = advertiser_deals.length

      clients << { client_name: advertiser.name, win_rate: win_rate, total_deals: total_deals }
    end
    clients.sort_by{|el| [el[:total_deals] * -1, el[:win_rate] * -1, el[:client_name]]}
  end

  def where_to_pitch_by_agency
    clients = []
    agencies.each do |agency|
      agency_deals = agency_deals_list(agency.id)
      next if agency_deals.length == 0

      if params[:category_id] || params[:subcategory_id]
        related_advertisers = company.clients.where(id: agency_deals.map(&:advertiser_id).compact.uniq)

        if params[:category_id]
          next unless related_advertisers.map(&:client_category_id).include?(params[:category_id].to_i)
        end

        if params[:subcategory_id]
          next unless related_advertisers.map(&:client_subcategory_id).include?(params[:subcategory_id].to_i)
        end
      end

      complete_deals = complete_deals_list(agency_deals)
      incomplete_deals = incomplete_deals_list(agency_deals)

      win_rate = 0.0
      win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0

      total_deals = agency_deals.length

      clients << { client_name: agency.name, win_rate: win_rate, total_deals: total_deals }
    end
    clients.sort_by{|el| [el[:total_deals] * -1, el[:win_rate] * -1, el[:client_name]]}
  end

  def complete_deals_list(deals)
    deals.select do |deal|
      deal.closed_at &&
      deal.closed_at >= start_date &&
      deal.closed_at <= end_date &&
      deal.stage.probability == 100
    end
  end

  def incomplete_deals_list(deals)
    deals.select do |deal|
      deal.closed_at &&
      deal.closed_at >= start_date &&
      deal.closed_at <= end_date &&
      deal.stage.probability == 0 &&
      deal.stage.open == false
    end
  end

  def deal_member_ids
    if params[:seller] && params[:seller] !='all'
      @team_members ||= [params[:seller]]
    else
      @team_members ||= teams.map(&:all_sales_reps).flatten.map(&:id)
    end
  end

  def teams
    if params[:team] && params[:team] != 'all'
      @teams ||= [company.teams.find(params[:team])]
    else
      @teams ||= root_teams
    end
  end

  def root_teams
    company.teams.roots(true)
  end

  def company
    @company ||= current_user.company
  end

  def start_date
    if params[:start_date]
      Date.parse(params[:start_date])
    else
      (Date.current - 6.months).beginning_of_month
    end
  end

  def end_date
    if params[:end_date]
      Date.parse(params[:end_date])
    else
      (Date.current - 1.months).end_of_month
    end
  end

  def advertisers
    company.clients
      .by_type_id(advertiser_type_id)
      .by_category(params[:category_id])
      .by_subcategory(params[:subcategory_id])
  end

  def agencies
    company.clients
      .by_type_id(agency_type_id)
  end

  def advertiser_deals_list(client_id)
    deals_by_time_period.select do |deal|
      (if params[:product_id] && params[:product_id] != 'all'
          deal.products.map(&:id).include?(params[:product_id].to_i)
       else
          true
       end) &&
      deal.advertiser_id == client_id
    end
  end

  def agency_deals_list(client_id)
    deals_by_time_period.select do |deal|
      (if params[:product_id] && params[:product_id] != 'all'
          deal.products.map(&:id).include?(params[:product_id].to_i)
       else
          true
       end) &&
      deal.agency_id == client_id
    end
  end

  def deals_by_time_period
    @deals ||= Deal.joins('LEFT JOIN deal_members on deals.id = deal_members.deal_id')
      .where('deal_members.user_id in (?)', deal_member_ids)
      .where(company_id: company.id)
      .distinct
      .active
      .includes(:stage, :deal_members, :products)
  end

  def advertiser_type_id
    Client.advertiser_type_id(current_user.company)
  end

  def agency_type_id
    Client.agency_type_id(current_user.company)
  end
end
