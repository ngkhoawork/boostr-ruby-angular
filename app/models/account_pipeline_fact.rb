class AccountPipelineFact < ActiveRecord::Base
  belongs_to :company
  belongs_to :account_dimension
  belongs_to :time_dimension
end