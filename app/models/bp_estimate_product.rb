class BpEstimateProduct < ActiveRecord::Base
  belongs_to :bp_estimate
  belongs_to :product
end
