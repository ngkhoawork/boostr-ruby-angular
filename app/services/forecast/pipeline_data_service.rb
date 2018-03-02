class Forecast::PipelineDataService
  def initialize(company, params)
    @company             = company
    @team_id             = params[:team_id]
    @product_family_id   = params[:product_family_id]
    @product_id          = params[:product_id]
    @member_id           = params[:member_id] || params[:user_id]
    @time_period_id      = params[:time_period_id]
    @is_net_forecast     = (params[:is_net_forecast] && params[:is_net_forecast] == 'true')
    @type                = params[:type]
  end

  def perform
    ActiveModel::ArraySerializer.new(
      data_for_serializer,
      each_serializer: serializer,
      filter_start_date: start_date,
      filter_end_date: end_date,
      products: products,
      members: members,
      is_net_forecast: is_net_forecast,
    )
  end

  private

  attr_reader :company,
              :team_id,
              :product_family_id,
              :product_id,
              :member_id,
              :is_net_forecast,
              :type,
              :time_period_id

  def serializer
    case type
    when 'quarterly'
      Forecast::PipelineQuarterlyDataSerializer
    else
      Forecast::PipelineDataSerializer
    end
  end

  def data_for_serializer
    @_data_for_serializer ||= if product_ids.present?
      deals.inject([]) do |results, deal|
        results << deal if deal_has_products?(deal)
        results
      end
    else
      deals
    end
  end

  def deal_has_products?(deal)
    deal.deal_products.each do |deal_product|
      return true if product_ids.include?(deal_product.product_id)
    end
    false
  end

  def deals
    @_deals ||= all_deals
      .includes({
        agency: {},
        advertiser: {},
        stage: {},
        company: {},
        deal_members: {},
        deal_products: {
          deal_product_budgets: {},
          product: {}
        }
      }).flatten.uniq
  end

  def all_deals
    @_all_deals ||= if member_or_team
      member_or_team.all_deals_for_time_period(start_date, end_date)
    else
      company.deals.for_time_period(start_date, end_date)
    end
  end

  def time_period
    @_time_period ||= company.time_periods.find(time_period_id)
  end

  def start_date
    @_start_date ||= time_period.start_date
  end

  def end_date
    @_end_date ||= time_period.end_date
  end

  def member_or_team
    @_member_or_team ||= if is_member_id_valid
      member
    elsif is_team_id_valid
      team
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def member
    @_member ||= company.users.find(member_id)
  end

  def members
    @_members ||= if is_member_id_valid
      [member]
    elsif is_team_id_valid
      team.all_members + team.all_leaders
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def is_member_id_valid
    @_is_member_id_valid ||= member_id && member_id != 'all'
  end

  def is_team_id_valid
    @_is_team_id_valid ||= team_id && team_id != 'all'
  end

  def team
    @_team ||= company.teams.find(team_id)
  end

  def product
    @_product ||= company.products.find_by_id(product_id)
  end

  def products
    @_products ||= if product.present?
      [product]
    elsif product_family
      product_family.products
    end
  end

  def product_ids
    @_product_ids ||= if products.present?
      products.collect(&:id)
    end
  end

  def product_family
    @_product_family ||= company.product_families.find_by_id(product_family_id)
  end
end
