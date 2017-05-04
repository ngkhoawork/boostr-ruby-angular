class BpEstimate < ActiveRecord::Base
  belongs_to :bp
  belongs_to :client
  belongs_to :user
  has_many :bp_estimate_products

  accepts_nested_attributes_for :bp_estimate_products

  scope :incomplete, -> (value) { if value == true then where('bp_estimates.estimate_seller IS NULL OR bp_estimates.estimate_seller = 0') end }
  scope :unassigned, -> (value) { if value == true then where('bp_estimates.user_id IS NULL') end}
  scope :assigned, -> { where('bp_estimates.user_id IS NOT NULL') }

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

  def client_name
    client.name
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
        methods: [:client_name, :user_name]
    })
  end

  def time_dimension
    TimeDimension.find_by(start_date: self.bp.time_period.start_date, end_date: self.bp.time_period.end_date)
  end

  def generate_bp_estimate_products
    bp.company.products.each do |product|
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
