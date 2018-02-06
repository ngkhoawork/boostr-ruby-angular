class ProductOption < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :product_option, class_name: "ProductOption"
  has_many   :sub_options,
             class_name: "ProductOption",
             dependent: :destroy
  has_many :product

  scope :root_options, -> () { where(product_option_id: nil) }

  validates :name, :company, presence: true
  validate :validate_unique_name

  private

  def validate_unique_name
    return unless company && name
    scope = neighbour_options.where('LOWER(name) = ?', name.downcase)
    scope = scope.where('id <> ?', id) if id
    errors.add(:name, 'Name has already been taken') if scope.count > 0
  end

  def neighbour_options
    if product_option
      product_option.sub_options
    elsif company
      company.product_options.root_options
    end
  end
end