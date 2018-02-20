class Forecast::RevenueDataService
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
      each_serializer: Forecast::RevenueDataSerializer,
      filter_start_date: start_date,
      filter_end_date: end_date,
      product_ids: product_ids,
      member_ids: member_ids,
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
      ios.inject([]) do |results, io|
        results << io if io_has_products?(io)
        results
      end
    else
      ios
    end
  end

  def io_has_products?(io)
    io.content_fees.each do |item|
      return true if product_ids.include?(item.product_id)
    end
    io.display_line_items.each do |item|
      return true if product_ids.include?(item.product_id)
    end
    false
  end

  def ios
    @_ios ||= company.ios
      .for_io_members(member_ids)
      .for_time_period(start_date, end_date)
      .distinct
      .includes({
        io_members: {
          user: {}
        },
        content_fees: {
          content_fee_product_budgets: {}
        },
        costs: {
          cost_monthly_amounts: {}
        },
        display_line_items: {
          display_line_item_budgets: {}
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
    @_members ||= if member_id
      [member]
    elsif team_id
      team.all_members + team.all_leaders
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def member_ids
    @_member_ids ||= members.collect(&:id) if members
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
