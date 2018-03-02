class Quota < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :time_period
  belongs_to :company
  belongs_to :product, polymorphic: true

  enum value_type: ::QUOTA_TYPES

  scope :for_time_period, -> (start_date, end_date) { joins(:time_period).where('time_periods.start_date=? and time_periods.end_date=?', start_date, end_date) unless start_date.nil? || end_date.nil?}
  scope :by_type, -> (value_type) { where(value_type: value_type) unless value_type.nil? }
  scope :by_product_type, -> (product_type) { where(product_type: product_type) unless product_type.nil? }
  scope :by_product_id, -> (product_id) { where(product_id: product_id) unless product_id.nil? }

  before_save :set_dates

  validates :user_id, :time_period_id, :company_id, :value_type, presence: true
  validates_uniqueness_of :time_period, :scope => [:product_type, :product_id, :value_type, :user_id], message: 'has already been taken along with user, product and type'

  def as_json(options={})
    super(options.merge(
      include: [:product],
      methods: [:user_name]
    ))
  end

  def user_name
    user.name if user
  end

  def set_dates
    self.start_date ||= self.time_period.try(:start_date)
    self.end_date ||= self.time_period.try(:end_date)
  end
end
