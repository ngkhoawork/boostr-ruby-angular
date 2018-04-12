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
    all_advertiser_deals = deals_by_time_period.group_by(&:advertiser_id)

    advertisers.each do |advertiser|
      advertiser_deals = all_advertiser_deals[advertiser.id]
      next if advertiser_deals.nil?

      complete_deals = advertiser_deals.count{|item| item.probability == 100 }
      incomplete_deals = advertiser_deals.count{|item| item.probability == 0 }

      win_rate = 0.0
      win_rate = (complete_deals.to_f / (complete_deals.to_f + incomplete_deals.to_f) * 100).round(0) if (incomplete_deals + complete_deals) > 0

      total_deals = advertiser_deals.length

      clients << { client_name: advertiser.name, win_rate: win_rate, total_deals: total_deals }
    end
    clients.sort_by{|el| [el[:total_deals] * -1, el[:win_rate] * -1, el[:client_name]]}
  end

  def where_to_pitch_by_agency
    clients = []
    all_agency_deals = deals_by_time_period.group_by(&:agency_id)

    agencies.each do |agency|
      agency_deals = all_agency_deals[agency.id]
      next if agency_deals.nil?

      complete_deals = agency_deals.count{|item| item.probability == 100 }
      incomplete_deals = agency_deals.count{|item| item.probability == 0 }

      win_rate = 0.0
      win_rate = (complete_deals.to_f / (complete_deals.to_f + incomplete_deals.to_f) * 100).round(0) if (incomplete_deals + complete_deals) > 0

      total_deals = agency_deals.length

      clients << { client_name: agency.name, win_rate: win_rate, total_deals: total_deals }
    end
    clients.sort_by{|el| [el[:total_deals] * -1, el[:win_rate] * -1, el[:client_name]]}
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
    @_advertisers ||= company.clients
                               .by_type_id(advertiser_type_id)
                               .by_category(params[:category_id])
                               .by_subcategory(params[:subcategory_id])
                               .pluck_to_struct(:id, :name)
  end

  def agencies
    company.clients
      .by_type_id(agency_type_id)
      .pluck_to_struct(:id, :name)
  end

  def deals_by_time_period
    @deals ||= Deal.joins('LEFT JOIN deal_members on deals.id = deal_members.deal_id')
      .where('deal_members.user_id in (?)', deal_member_ids)
      .where(company_id: company.id)
      .by_advertisers(category_filtered_advertisers)
      .by_product_id(product_ids)
      .where('stage_id in (?)', closed_stages)
      .where("deals.#{date_criteria_filter} >= ? and deals.#{date_criteria_filter} <= ?", start_date, end_date)
      .distinct
      .includes(:stage)
      .pluck_to_struct(:id, :advertiser_id, :agency_id, 'stages.probability as probability')
  end

  def product_ids
    @_product_ids ||= if params[:product_id].present?
      Product.include_children(company.products.where(id: params[:product_id]))
    end
  end

  def category_filtered_advertisers
    if params[:category_id].present? || params[:subcategory_id].present?
      advertisers.map(&:id)
    else
      nil
    end
  end

  def advertiser_type_id
    Client.advertiser_type_id(current_user.company)
  end

  def agency_type_id
    Client.agency_type_id(current_user.company)
  end

  def closed_stages
    Stage.where(company_id: company.id, active: true, open: false).where('probability in (?)', [0, 100]).ids
  end

  def date_criteria_filter
    if params[:date_criteria] == 'created_date'
      'created_at'
    else
      'closed_at'
    end
  end
end
