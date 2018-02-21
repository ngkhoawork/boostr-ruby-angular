class Forecast::PipelineProductDataService
  def initialize(company, params)
    @company             = company
    @team_id             = params[:team_id]
    @product_family_id   = params[:product_family_id]
    @product_id          = params[:product_id]
    @member_id           = params[:member_id]
    @time_period_id      = params[:time_period_id]
  end

  def perform
    ActiveModel::ArraySerializer.new(
      data_for_serializer,
      each_serializer: Forecast::PipelineDataSerializer,
      filter_start_date: start_date,
      filter_end_date: end_date,
      products: products,
    )
  end

  private

  attr_reader :company,
              :team_id,
              :product_family_id,
              :product_id,
              :member_id,
              :time_period_id

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
    @_deals ||= member_or_team
      .all_deals_for_time_period(start_date, end_date)
      .includes({
        agency: {},
        advertiser: {},
        stage: {},
        company: {},
        deal_products: {
          deal_product_budgets: {},
          product: {}
        }
      }).flatten.uniq
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
    @_member_or_team ||= if member_id
      member
    elsif team_id
      team
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def member
    @_member ||= company.users.find(member_id)
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
