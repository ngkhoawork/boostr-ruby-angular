class Report::ProductMonthlySummaryService
  def initialize(company, params)
    @company             = company
    @team_id             = params[:team_id]
    @product_id          = params[:product_id]
    @seller_id           = params[:seller_id]
    @created_date_start  = params[:created_date_start]
    @created_date_end    = params[:created_date_end]
    @page                = params[:page] ? params[:page].to_i : nil
    @per_page            = params[:per_page] ? params[:per_page].to_i : nil
  end

  def perform
    {
      data: ActiveModel::ArraySerializer.new(
        data_for_serializer,
        each_serializer: Report::ProductMonthlySummarySerializer,
        deal_custom_fields: deal_custom_fields,
        deal_product_cf_names: deal_product_cf_names
      ),
      deal_product_cf_names: deal_product_cf_names,
      has_more_data: has_more_data,
    }
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
            .limit(limit)
            .offset(offset)
    @_deals
  end

  def has_more_data
    deals.count > 0 ? true : false
  end

  def data_for_serializer
    deals.inject([]) do |results, deal|
      if deal.closed_with_io?
        results += data_for_io(deal)
      else
        results += data_for_deal(deal)
      end
      results
    end
  end

  def data_for_io(deal)
    data_for_io_content_fee(deal.io) +
      data_for_io_display_line_item(deal.io) +
      data_for_deal(deal, true)
  end

  def data_for_io_content_fee(io)
    io.content_fees.inject([]) do |results, content_fee|
      if !product_id || product_ids.include?(content_fee.product_id)
        results += content_fee.content_fee_product_budgets
      end
      results
    end
  end

  def data_for_io_display_line_item(io)
    io.display_line_items.inject([]) do |results, display_line_item|
      if !product_id || product_ids.include?(display_line_item.product_id)
        results += display_line_item.display_line_item_budgets
      end
      results
    end
  end

  def data_for_deal(deal, only_open = false)
    deal.deal_products.inject([]) do |results, deal_product|
      if (!product_id || product_ids.include?(deal_product.product_id)) &&
          (!only_open || deal_product.open)
        results += deal_product.deal_product_budgets
      end
      results
    end
  end

  def product_ids
    @_product_ids ||= [product_id.to_i].compact + (Product.find_by(id: product_id)&.all_children&.map(&:id) || [])
  end

  def deal_product_cf_names
    @_deal_product_cf_names ||= company.deal_product_cf_names.active.position_asc || []
  end

  def deal_custom_fields
    @_deal_custom_fields ||= company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end

  def limit
    @_limit ||= per_page
  end

  def offset
    @_offset ||= (per_page && page) ? (page - 1) * limit : nil
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
                deal: {
                  deal_products: {
                    deal_product_cf: {}
                  }
                },
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
                deal: {
                  deal_products: {
                    deal_product_cf: {}
                  }
                },
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
