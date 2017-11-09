class Report::ProductMonthlySummaryService
  def initialize(company, params)
    @company             = company
    @team_id             = params[:team_id]
    @product_id          = params[:product_id]
    @seller_id           = params[:seller_id]
    @created_date_start  = params[:created_date_start]
    @created_date_end    = params[:created_date_end]
    @page                = params[:page].to_i rescue nil
    @per_page            = params[:per_page].to_i rescue nil
  end

  def perform
    data = {
      data: ActiveModel::ArraySerializer.new(
        data_for_serializer,
        each_serializer: Report::ProductMonthlySummarySerializer,
        deal_custom_fields: deal_custom_fields,
        deal_product_cf_names: deal_product_cf_names
      ),
      deal_product_cf_names: deal_product_cf_names
    }

    if deals.count > 0
      data[:has_more_data] = true
    else
      data[:has_more_data] = false
    end
    data    
  end

  private

  attr_reader :company,
              :team_id,
              :product_id,
              :seller_id,
              :created_date_start,
              :created_date_end,
              :page,
              :per_page

  def deals
    @_deals ||= company.deals
            .includes(deal_include_json)
            .by_team_id(team_id)
            .by_seller_id(seller_id)
            .by_created_date(created_date_start, created_date_end)
    if page && per_page && page > 0 && per_page > 0
      offset = (page - 1) * per_page
      @_deals = @_deals.limit(per_page).offset(offset)
    end
    @_deals
  end

  def data_for_serializer
    results = []
    deals.each do |deal|
      if deal.closed_with_io?
        deal.io.content_fees.each do |content_fee|
          next if product_id && content_fee.product_id != product_id.to_i
          results += content_fee.content_fee_product_budgets
        end

        deal.io.display_line_items.each do |display_line_item|
          next if product_id && display_line_item.product_id != product_id.to_i
          results += display_line_item.display_line_item_budgets
        end

        deal.deal_products.each do |deal_product|
          next if product_id && deal_product.product_id != product_id.to_i || deal_product.open == false
          results += deal_product.deal_product_budgets
        end
      else
        deal.deal_products.each do |deal_product|
          next if product_id && deal_product.product_id != product_id.to_i
          results += deal_product.deal_product_budgets
        end
      end
    end
    results
  end

  def deal_product_cf_names
    @_deal_product_cf_names ||= company.deal_product_cf_names.position_asc || []
  end

  def deal_custom_fields
    @_deal_custom_fields ||= company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end

  def deal_include_json
    @_deal_include_json ||= {
      stage: {},
      io: {
        content_fees: {
          content_fee_product_budgets: {
            content_fee: {
              product: {},
              io: {
                io_members: [{ user: :team }],
                company: {},
                currency: {},
                agency: [:holding_company],
                advertiser: [:client_category]
              }
            }
          }
        },
        display_line_items: {
          display_line_item_budgets: {
            display_line_item: {
              product: {},
              io: {
                io_members: [{ user: :team }],
                company: {},
                currency: {},
                agency: [:holding_company],
                advertiser: [:client_category]
              }
            }
          }
        }
      },
      deal_products: {
        deal_product_budgets: {
          deal_product: {
            product: {},
            deal_product_cf: {},
            deal: {
              deal_members: [{ user: :team }],
              company: {
                deal_product_cf_names: {}
              },
              stage: {},
              deal_custom_field: {},
              currency: {},
              io: {},
              values: [:option],
              agency: [:holding_company],
              advertiser: [:client_category]
            }
          }
        },
      },
    }
  end
end
