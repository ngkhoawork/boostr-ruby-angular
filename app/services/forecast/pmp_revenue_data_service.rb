class Forecast::PmpRevenueDataService
  def initialize(company, params, is_product = false)
    @company             = company
    @team_id             = params[:team_id]
    @product_family_id   = params[:product_family_id]
    @product_id          = params[:product_id]
    @member_id           = params[:member_id] if params[:member_id]
    @member_id           = params[:user_id] if params[:user_id]
    @time_period_id      = params[:time_period_id]
    @is_product          = is_product
  end

  def perform
    if is_product
      ActiveModel::ArraySerializer.new(
        data_for_serializer,
        each_serializer: Forecast::PmpRevenueProductDataSerializer,
        filter_start_date: start_date,
        filter_end_date: end_date,
        product_ids: product_ids,
        member_ids: member_ids,
      )
    else
      ActiveModel::ArraySerializer.new(
        data_for_serializer,
        each_serializer: Forecast::PmpRevenueDataSerializer,
        filter_start_date: start_date,
        filter_end_date: end_date,
        product_ids: product_ids,
        member_ids: member_ids,
      )
    end
  end

  private

  attr_reader :company,
              :team_id,
              :product_family_id,
              :product_id,
              :member_id,
              :is_product,
              :time_period_id

  def data_for_serializer
    @_data_for_serializer ||= if product_ids.present?
      pmps.inject([]) do |results, pmp|
        results << pmp if pmp_has_products?(pmp)
        results
      end
    else
      pmps
    end
  end

  def pmp_has_products?(pmp)
    pmp.pmp_items.each do |item|
      return true if product_ids.include?(item.product_id)
    end
    false
  end

  def pmps
    @_pmps ||= company.pmps
      .for_pmp_members(member_ids)
      .for_time_period(start_date, end_date)
      .distinct
      .includes({
        pmp_members: {
          user: {}
        },
        pmp_items: {
          pmp_item_daily_actuals: {}
        },
        agency: {},
        advertiser: {},
        company: {}
      })
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

  def members
    @_members ||= if member_id && member_id != 'all'
      [member]
    elsif team_id && team_id != 'all'
      team.all_members + team.all_leaders
    end
  end

  def member_ids
    @_member_ids ||= members.collect(&:id) if members.present?
  end

  def member
    @_member ||= company.users.find(member_id) if member_id != 'all'
  end

  def team
    @_team ||= company.teams.find(team_id) if team_id != 'all'
  end

  def product
    @_product ||= company.products.find_by_id(product_id)
  end

  def products
    @_products ||= if product.present?
      [product]
    elsif product_family
      [product_family.products]
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
