class HoldingCompany < ActiveRecord::Base
  has_many :contracts, dependent: :nullify
end
