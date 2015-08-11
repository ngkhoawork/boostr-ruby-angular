class Product < ActiveRecord::Base
  belongs_to :company
  has_many :deal_products

  validates :name, presence: true
end
