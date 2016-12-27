class BpEstimateProduct < ActiveRecord::Base
  belongs_to :bp_estimate
  belongs_to :product

  after_save :update_bp_estimate_budget

  def update_bp_estimate_budget
    bp_estimate.update(estimate_seller: bp_estimate.bp_estimate_products.sum(:estimate_seller))
    bp_estimate.update(estimate_mgr: bp_estimate.bp_estimate_products.sum(:estimate_mgr))
  end
end
