class BpEstimate < ActiveRecord::Base
  belongs_to :bp
  belongs_to :client
  belongs_to :user
  has_many :bp_estimate_products

  accepts_nested_attributes_for :bp_estimate_products

  scope :incomplete, -> (value) { if value == true then where('bp_estimates.estimate_seller IS NULL OR bp_estimates.estimate_seller = 0') end }
  scope :unassigned, -> (value) { if value == true then where('bp_estimates.user_id IS NULL') end}

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
end
