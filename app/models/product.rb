class Product < ActiveRecord::Base
  belongs_to :company
  has_many :deal_products
  has_many :values, as: :subject
  has_many :ad_units

  validates :name, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  scope :active, -> { where('active IS true') }

  def as_json(options = {})
    super(options.merge(include: [:ad_units, values: { include: [:option], methods: [:value] }]))
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def self.get_option_value(subject, field_name)
    if !subject.nil?
      subject_fields = subject.fields
      if !subject_fields.nil?
        field = subject_fields.find_by_name(field_name)
        value = subject.values.find_by_field_id(field.id) if !field.nil?
        option = value.option.name if !value.nil? && !value.option.nil?
      end
     end
    return option
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << ["Product ID", "Product Name", "Pricing Type", "Product Line", "Product Family", "Active"]
      all.each do |product|
        csv << [
          product.id,
          product.name,
          get_option_value(product, "Pricing Type"),
          get_option_value(product, "Product Line"),
          get_option_value(product, "Product Family"),
          product.active ? "Yes" : "No"
        ]
      end
    end
  end

end
