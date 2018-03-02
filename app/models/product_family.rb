class ProductFamily < ActiveRecord::Base
  belongs_to :company
  has_many :products
  has_many :quotas, as: :product

  validates :name, presence: true

  scope :active, -> (active) { where('active IS true') if active }

  before_destroy :remove_product_relations

  def remove_product_relations
    self.products.update_all(product_family_id: nil)
  end
end
