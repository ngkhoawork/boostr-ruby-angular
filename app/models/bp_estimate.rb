class BpEstimate < ActiveRecord::Base
  belongs_to :bp
  belongs_to :client
  belongs_to :user
  has_many :bp_estimate_products

  accepts_nested_attributes_for :bp_estimate_products

  def client_name
    client.name
  end

  def user_name
    user.name
  end
end
