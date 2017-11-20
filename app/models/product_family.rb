class ProductFamily < ActiveRecord::Base
  belongs_to :company

  validates :name, presence: true

  scope :active, -> (active) { where('active IS true') if active }
end
