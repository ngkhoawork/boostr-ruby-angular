class AccountProductRevenueFact < ActiveRecord::Base
  belongs_to :account_dimension
  belongs_to :time_dimension
  belongs_to :company
  belongs_to :product_dimension
end
