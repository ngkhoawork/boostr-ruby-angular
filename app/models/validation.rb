class Validation < ActiveRecord::Base
  belongs_to :company

  has_one :criterion, class_name: 'Value', as: :subject, dependent: :destroy

  validates :company, :factor, presence: :true
  validates_uniqueness_of :factor, scope: [:company_id, :object]

  accepts_nested_attributes_for :criterion

  delegate :value, to: :criterion, allow_nil: true

  after_create do
    self.create_criterion unless criterion.present?
  end

  scope :account_base_fields, -> do
    where('object in (?)', ['Advertiser Base Field', 'Agency Base Field', 'Account Custom Validation'])
        .joins(:criterion)
        .where('values.value_boolean = ?', true)
  end

  scope :deal_base_fields, -> do
    where(object: 'Deal Base Field')
        .joins(:criterion)
        .where('values.value_boolean = ?', true)
  end

  scope :billing_contact_fields, -> do
    where(factor: 'Billing Contact Full Address')
        .joins(:criterion)
        .where('values.value_boolean = ?', true)
  end

  scope :by_factor, ->(factor) { where(factor: factor) unless factor.nil? }

  def as_json(options = {})
    super(options.merge(
      include: {
        criterion: {
          methods: [:value]
        }
      },
      methods: [:name]
    ))
  end

  def name
    case self.factor
    when 'client_category_id'
      'Category'
    when 'client_subcategory_id'
      'Subcategory'
    when 'client_region_id'
      'Region'
    when 'client_segment_id'
      'Segment'
    when 'deal_type_value'
      'Deal Type'
    when 'deal_source_value'
      'Deal Source'
    else
      self.factor.titleize
    end
  end
end
