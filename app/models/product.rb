class Product < ActiveRecord::Base
  belongs_to :company
  has_many :deal_products
  has_many :values, as: :subject

  validates :name, presence: true

  accepts_nested_attributes_for :values

  def as_json(options = {})
    super(options.merge(include: [values: { include: [:option], methods: [:value] }]))
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end
end
