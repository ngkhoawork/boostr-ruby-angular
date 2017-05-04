class AccountCf < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
end
