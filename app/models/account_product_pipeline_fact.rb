class AccountProductPipelineFact < ActiveRecord::Base
  belongs_to :product
  belongs_to :time_dimension
  belongs_to :account_dimension
  belongs_to :company
end
