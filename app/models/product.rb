class Product < ActiveRecord::Base
  belongs_to :company
  has_many :deal_products
  has_many :values, as: :subject

  validates :name, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  def as_json(options = {})
    super(options.merge(include: [values: { include: [:option], methods: [:value] }]))
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << ["Product ID", "Product Name", "Pricing Type", "Product Line", "Product Family"]
      all.each do |product|
        if product.values.present? && product.fields.present?
          pricing_type_field = product.fields.find_by_name("Pricing Type")
          pricing_type_value = product.values.find_by_field_id(pricing_type_field.id) if pricing_type_field.present?
          pricing_type = pricing_type_value.option.name if pricing_type_value.present? && pricing_type_value.option.present?
          product_line_field = product.fields.find_by_name("Product Line")
          product_line_value = product.values.find_by_field_id(product_line_field.id) if product_line_field.present?
          product_line = product_line_value.option.name if product_line_value.present? && product_line_value.option.present?
          product_family_field = product.fields.find_by_name("Product Family")
          product_family_value = product.values.find_by_field_id(product_family_field.id) if product_family_field.present?
          product_family = product_family_value.option.name if product_family_value.present? && product_family_value.option.present?
        end
        csv << [product.id, product.name, pricing_type, product_line, product_family]
      end
    end
  end

end
