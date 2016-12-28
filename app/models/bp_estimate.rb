class BpEstimate < ActiveRecord::Base
  belongs_to :bp
  belongs_to :client
  belongs_to :user
  has_many :bp_estimate_products

  accepts_nested_attributes_for :bp_estimate_products

  scope :incomplete, -> (value) { if value == true then where('bp_estimates.estimate_seller IS NULL OR bp_estimates.estimate_seller = 0') end }
  scope :unassigned, -> (value) { if value == true then where('bp_estimates.user_id IS NULL') end}
  scope :assigned, -> { where('bp_estimates.user_id IS NOT NULL') }

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
end
