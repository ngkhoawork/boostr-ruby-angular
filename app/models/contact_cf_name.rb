class ContactCfName < ActiveRecord::Base
  belongs_to :company, required: true
  has_many   :contact_cf_options, -> { order 'LOWER(value)' }, dependent: :destroy

  validates :field_type, presence: true
  validate  :field_type_within_limit, on: :create
  validate  :field_type_permitted

  accepts_nested_attributes_for :contact_cf_options

  default_scope { order(position: :asc) }

  scope :for_company, -> (id) { where(company_id: id) }
  scope :by_type,  -> type { where(field_type: type) if type.present? }
  scope :by_index, -> index { where(field_index: index) if index.present? }

  before_create do
    assign_index
  end

  after_create do
    update_contact_cfs
  end

  FIELD_LIMITS = {
    "currency" => 10,
    "text" => 10,
    "note" => 10,
    "datetime" => 10,
    "number" => 10,
    "number_4_dec" => 10,
    "integer" => 10,
    "boolean" => 10,
    "percentage" => 10,
    "dropdown" => 10
  }

  def underscored_field_label
    field_label.parameterize.underscore
  end

  def field_name
    "#{field_type}#{field_index}"
  end

  private

  def assign_index
    indices = ContactCfName.for_company(company_id)
                           .by_type(field_type)
                           .pluck(:field_index)

    for i in 1..field_limit
      if indices.index(i).nil?
        self.field_index = i
        break
      end
    end
  end

  def update_contact_cfs
    field_name = self.field_type + self.field_index.to_s
    self.company.contact_cfs.update_all(field_name => nil)
  end

  def field_type_within_limit
    return unless self.field_type

    count = ContactCfName.for_company(company_id)
                         .by_type(field_type)
                         .count

    if field_limit.present? && count >= field_limit
      errors.add(:field_type, "#{self.field_type.capitalize} reached it's limit of #{field_limit}")
    end
  end

  def field_type_permitted
    if field_type.present? && !(field_limit.present?)
      errors.add(:field_type, "#{self.field_type.capitalize} is not permitted for Contacts")
    end
  end

  def field_limit
    FIELD_LIMITS[self.field_type]
  end
end
