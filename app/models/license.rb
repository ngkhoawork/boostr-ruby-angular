class License < ActiveRecord::Base
  has_many :contracts
  has_many :companies, through: :contracts
end
