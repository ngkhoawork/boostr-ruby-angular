class BpEstimate < ActiveRecord::Base
  belongs_to :bp
  belongs_to :client
  belongs_to :user
  has_many :bp_estimate_products, dependent: :destroy

  accepts_nested_attributes_for :bp_estimate_products

  scope :incomplete, -> (value) { if value == true then where('bp_estimates.user_id IS NOT NULL AND (bp_estimates.estimate_seller IS NULL OR bp_estimates.estimate_seller = 0)') end }
  scope :completed, -> (value) { if value == true then where('bp_estimates.user_id IS NULL OR (bp_estimates.estimate_seller IS NOT NULL AND bp_estimates.estimate_seller != 0)') end }
  scope :unassigned, -> (value) { if value == true then where('bp_estimates.user_id IS NULL') end}
  scope :assigned, -> { where('bp_estimates.user_id IS NOT NULL') }
  scope :has_status, -> { where('bp_estimates.user_id IS NOT NULL AND bp_estimates.estimate_seller > 0 AND bp_estimates.client_id IS NOT NULL') }
  scope :by_user_ids, -> (user_ids) { where(user_id: user_ids) if user_ids && user_ids.count > 0 }
  scope :order_by_client_name, -> { order('clients.name') }

  after_update do
    total = bp_estimate_products.sum(:estimate_seller)
    if total != estimate_seller
      if estimate_seller_changed?
        self.update_product_estimate_seller
      elsif total > 0
        self.update_estimate_seller
      end
    end
  end

  after_update do
    total = bp_estimate_products.sum(:estimate_mgr)
    if bp_estimate_products.sum(:estimate_mgr) != estimate_mgr
      if estimate_mgr_changed?
        self.update_product_estimate_mgr
      elsif total > 0
        self.update_estimate_mgr
      end
    end
  end

  after_create :generate_bp_estimate_products

  def self.to_csv(bp, bp_estimates, company)
    time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", bp.time_period.start_date, bp.time_period.end_date).to_a
    year_time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", bp.time_period.start_date - 1.years, bp.time_period.end_date -  1.years).to_a
    prev_time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", (bp.time_period.start_date - 3.months).beginning_of_month, (bp.time_period.end_date -  3.months).end_of_month).to_a
    time_dimension_name = time_dimensions[0].name if time_dimensions.count > 0
    year_time_dimension_name = year_time_dimensions[0].name if year_time_dimensions.count > 0
    prev_time_dimension_name = prev_time_dimensions[0].name if prev_time_dimensions.count > 0
    products = company.products.active
    CSV.generate do |csv|
      header = [
        "Account",
        "Category",
        "Region",
        "Segment",
        "Primary Agency",
        "Seller",
        "#{time_dimension_name} Pipeline (W)",
        "#{time_dimension_name} Revenue",
        "#{time_dimension_name} Estimate",
        "Mgr Estimate",
        "#{year_time_dimension_name} Revenue",
        "% Change - YoY",
        "#{prev_time_dimension_name} Revenue",
        "% Change - QoQ"
      ]

      products.each do |product|
        header << "#{product.name} Seller Estimate"
        header << "#{product.name} Mgr Estimate"
      end

      csv << header
      bp_estimates
      .each do |bp_estimate|
        pipeline_amount = 0
        revenue_amount = 0
        year_pipeline_amount = 0
        year_revenue_amount = 0
        prev_pipeline_amount = 0
        prev_revenue_amount = 0
        if time_dimensions.count > 0
          pipelines = AccountPipelineFact.where("company_id = ? and time_dimension_id = ? and account_dimension_id = ?", bp.company.id, time_dimensions[0].id, bp_estimate.client_id)
          revenues = AccountRevenueFact.where("company_id = ? and time_dimension_id = ? and account_dimension_id = ?", bp.company.id, time_dimensions[0].id, bp_estimate.client_id)

          if pipelines.count > 0
            pipeline_amount = pipelines[0].pipeline_amount
          end
          if revenues.count > 0
            revenue_amount = revenues[0].revenue_amount
          end
        end
        if year_time_dimensions.count > 0
          year_time_periods = TimePeriod.where(company_id: company.id, start_date: year_time_dimensions[0].start_date, end_date: year_time_dimensions[0].end_date)
          if year_time_periods.count > 0
            year_pipelines = AccountPipelineFact.where("company_id = ? and time_dimension_id = ? and account_dimension_id = ?", bp.company.id, year_time_dimensions[0].id, bp_estimate.client_id)
            year_revenues = AccountRevenueFact.where("company_id = ? and time_dimension_id = ? and account_dimension_id = ?", bp.company.id, year_time_dimensions[0].id, bp_estimate.client_id)
            year_time_period = year_time_periods[0]

            if year_pipelines.count > 0
              year_pipeline_amount = year_pipelines[0].pipeline_amount
            end
            if year_revenues.count > 0
              year_revenue_amount = year_revenues[0].revenue_amount
            end
          end
        end
        if prev_time_dimensions.count > 0
          prev_time_periods = TimePeriod.where(company_id: company.id, start_date: prev_time_dimensions[0].start_date, end_date: prev_time_dimensions[0].end_date)
          if prev_time_periods.count > 0
            prev_pipelines = AccountPipelineFact.where("company_id = ? and time_dimension_id = ? and account_dimension_id = ?", bp.company.id, prev_time_dimensions[0].id, bp_estimate.client_id)
            prev_revenues = AccountRevenueFact.where("company_id = ? and time_dimension_id = ? and account_dimension_id = ?", bp.company.id, prev_time_dimensions[0].id, bp_estimate.client_id)
            prev_time_period = prev_time_periods[0]

            if prev_pipelines.count > 0
              prev_pipeline_amount = prev_pipelines[0].pipeline_amount
            end
            if prev_revenues.count > 0
              prev_revenue_amount = prev_revenues[0].revenue_amount
            end
          end
        end
        year_change = nil
        if bp_estimate.estimate_seller && bp_estimate.estimate_seller > 0 && year_revenue_amount && year_revenue_amount> 0
          year_change = (bp_estimate.estimate_seller.to_f / year_revenue_amount.to_f - 1) * 100
        end
        prev_change = nil

        if bp_estimate.estimate_seller && bp_estimate.estimate_seller > 0 && prev_revenue_amount && prev_revenue_amount > 0
          prev_change = (bp_estimate.estimate_seller.to_f / prev_revenue_amount.to_f - 1) * 100
        end

        line = [
          bp_estimate.client&.name,
          bp_estimate.client&.client_category&.name,
          bp_estimate.client&.client_region&.name,
          bp_estimate.client&.client_segment&.name,
          bp_estimate.primary_agency_name,
          bp_estimate.user&.name,
          '$' + pipeline_amount.to_s,
          '$' + revenue_amount.to_s,
          '$' + (bp_estimate.estimate_seller || 0).to_s,
          '$' + (bp_estimate.estimate_mgr || 0).to_s,
          '$' + year_revenue_amount.to_s,
          year_change ? year_change.to_i.to_s + '%' : year_change,
          '$' + prev_revenue_amount.to_s,
          prev_change ? prev_change.to_i.to_s + '%' : prev_change
        ]

        product_data = bp_estimate.bp_estimate_products.inject({}) do |result, bp_estimate_product|
          result[bp_estimate_product.product_id] = {
            estimate_seller: bp_estimate_product.estimate_seller || 0,
            estimate_mgr: bp_estimate_product.estimate_mgr || 0,
          }
          result
        end



        products.each do |product|
          estimate_seller = product_data[product.id] ? product_data[product.id][:estimate_seller] : 0
          estimate_mgr = product_data[product.id] ? product_data[product.id][:estimate_mgr] : 0
          line << "$#{estimate_seller}"
          line << "$#{estimate_mgr}"
        end
        
        csv << line
      end
    end
  end

  def client_name
    client.name
  end

  def primary_agency
    primary_advertiser_connection = nil
    primary_advertiser_connection = client.advertiser_connections.where(primary: true).first if client.advertiser_connections.count > 0
    if primary_advertiser_connection.present?
      Client.find_by(id: primary_advertiser_connection.agency_id)
    end
  end

  def primary_agency_name
    self.primary_agency.name if self.primary_agency.present?
  end

  def user_name
    user.present? ? user.name : ""
  end

  def full_json
    self.as_json( {
        include: {
            bp_estimate_products: {
                include: {
                    product: {}
                }
            },
            client: {},
            user: {}
        },
        methods: [:client_name, :user_name, :primary_agency, :primary_agency_name]
    })
  end

  def time_dimension
    TimeDimension.find_by(start_date: self.bp.time_period.start_date, end_date: self.bp.time_period.end_date)
  end

  def generate_bp_estimate_products
    bp.company.products.active.each do |product|
      bp_estimate_product_param = {
          product_id: product.id,
          estimate_seller: nil,
          estimate_mgr: nil,
      }
      bp_estimate_products.create(bp_estimate_product_param)
    end
  end

  def update_product_estimate_seller
    bp_estimate_products.each do |bp_estimate_product|
      # bp_estimate_product.update(estimate_seller: nil)
      bp_estimate_product.estimate_seller = nil
      bp_estimate_product.save
    end
  end
  def update_product_estimate_mgr
    bp_estimate_products.each do |bp_estimate_product|
      bp_estimate_product.update(estimate_mgr: nil)
    end
  end

  def update_estimate_seller
    self.update(estimate_seller: bp_estimate_products.sum(:estimate_seller))

  end

  def update_estimate_mgr
    self.update(estimate_mgr: bp_estimate_products.sum(:estimate_mgr))
  end
end
