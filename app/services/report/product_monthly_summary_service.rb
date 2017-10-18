class Report::ProductMonthlySummaryService
  def initialize(company, params)
    @company             = company
    @team_id             = params[:team_id]
    @product_id          = params[:product_id]
    @seller_id           = params[:seller_id]
    @created_date_start  = params[:created_date_start]
    @created_date_end    = params[:created_date_end]
  end

  def perform
    {
      data: deals,
      deal_product_cf_names: deal_product_cf_names
    }
  end

  private

  attr_reader :company,
              :team_id,
              :product_id,
              :seller_id,
              :created_date_start,
              :created_date_end

  def deals
    deals = company.deals
            .includes(
              :stage,
              :deal_custom_field,
              :initiative,
              :currency,
              :products,
              :deal_product_budgets,
              :io,
              deal_members: [{ user: :team }],
              values: [:option],
              agency: [:holding_company],
              advertiser: [:client_category]
            )
            .by_team_id(team_id)
            .by_seller_id(seller_id)
            .by_created_date(created_date_start, created_date_end)

    results = []
    deals.each do |deal|
      if !deal.stage.open? && deal.stage.probability == 100 && deal.io.present?
        deal.io.content_fees.for_product_id(product_id).each do |content_fee|
          content_fee.content_fee_product_budgets.each do |budget|
            results << product_io(deal.io, content_fee.product, budget)
          end
        end

        deal.io.display_line_items.for_product_id(product_id).each do |display_line_item|
          display_line_item.display_line_item_budgets.each do |budget|
            results << product_io(deal.io, display_line_item.product, budget)
          end
        end
      else
        deal.deal_products.for_product_id(product_id).each do |deal_product|
          product = deal_product.product
          deal_product.deal_product_budgets.each do |budget|
            data = {}
            data['record_id'] = deal.id
            data['product_id'] = product.id
            data['product'] = product.name
            data['custom_fields'] = custom_fields(deal_product)
            data['record_type'] = 'Deal'
            data['members'] = members(deal.deal_members)
            data['advertiser'] = deal.advertiser.serializable_hash(only: [:id, :name]) rescue nil
            data['name'] = deal.name
            data['agency'] = deal.agency.serializable_hash(only: [:id, :name]) rescue nil
            data['holding_company'] = deal.agency.holding_company.name rescue nil
            data['stage'] = deal.stage.serializable_hash(only: [:name, :probability]) rescue {}
            data['budget'] = budget.budget
            data['weighted_budget'] = data['stage']['probability'].present? ? data['budget'].to_f * data['stage']['probability'].to_f / 100 : 0
            data['budget_loc'] = budget.budget_loc
            data['currency'] = deal.currency && deal.currency.curr_symbol
            data['currency_cd'] = deal.currency && deal.currency.curr_cd
            data['created_at'] = deal.created_at
            data['closed_at'] = deal.closed_at
            data['type'] = deal.get_option_value_from_raw_fields(deal_custom_fields, 'Deal Type')
            data['source'] = deal.get_option_value_from_raw_fields(deal_custom_fields, 'Deal Source')
            data['start_date'] = budget.start_date
            data['end_date'] = budget.end_date

            results << data
          end
        end
      end
    end

    results
  end

  def product_io(io, product, budget)
    data = {}
    data['record_id'] = io.id
    data['product'] = product.name
    data['product_id'] = product.id
    data['custom_fields'] = custom_fields(io.deal.deal_products.for_product_id(product.id).try(:first)) rescue {}
    data['record_type'] = 'IO'
    data['members'] = members(io.io_members)
    data['advertiser'] = io.advertiser.serializable_hash(only: [:id, :name]) rescue nil
    data['name'] = io.name
    data['agency'] = io.agency.serializable_hash(only: [:id, :name]) rescue nil
    data['holding_company'] = io.agency.holding_company.name rescue nil
    data['stage'] = {
      'name' => 'Revenue',
      'probability' => 100
    }
    data['created_at'] = io.created_at
    data['budget'] = budget.budget
    data['weighted_budget'] = data['stage']['probability'].present? ? data['budget'].to_f * data['stage']['probability'].to_f / 100 : 0
    data['budget_loc'] = budget.budget_loc
    data['start_date'] = budget.start_date
    data['end_date'] = budget.end_date
    data['currency'] = io.currency && io.currency.curr_symbol
    data['currency_cd'] = io.currency && io.currency.curr_cd
    data
  end

  def custom_fields(deal_product)
    result = {}
    if deal_product.deal_product_cf.present?
      deal_product_cf_names.each do |deal_product_cf_name|
        field_name = deal_product_cf_name.field_type.to_s + deal_product_cf_name.field_index.to_s
        result[field_name] = deal_product.deal_product_cf[field_name]
      end
    end
    result
  end

  def deal_product_cf_names
    @deal_product_cf_names ||= company.deal_product_cf_names.order("position asc") || []
  end

  def members(members)
    members.inject([]) do |data, obj|
      data << {
        id: obj.user_id,
        name: obj.user.name,
        share: obj.share
      }
    end
  end

  def deal_custom_fields
    company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end
end
