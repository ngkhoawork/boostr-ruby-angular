class DealProduct < ActiveRecord::Base
  belongs_to :deal
  belongs_to :product
end
