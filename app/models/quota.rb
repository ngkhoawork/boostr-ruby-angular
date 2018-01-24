class Quota < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :time_period
  belongs_to :company
  belongs_to :product, polymorphic: true

  enum value_type: ::QUOTA_TYPES

  scope :for_time_period, -> (start_date, end_date) { joins(:time_period).where('time_periods.start_date=? and time_periods.end_date=?', start_date, end_date)}

  before_save :set_dates

  validates :user_id, :time_period_id, :company_id, :value_type, presence: true
  validates_uniqueness_of :product, :scope => [:time_period_id, :value_type, :user_id], message: 'has already been taken along with user, time period and type'
  validate :validate_product_existence

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

  private 

  def validate_product_existence
    if product_type == 'Product' && product.product_family.present?
      quota = Quota.where(user_id: user_id, time_period_id: time_period_id, value_type: value_type, product_id: product.product_family_id, product_type: 'ProductFamily').first
      errors.add(:base, "Product Family - #{product.product_family.name} has already taken") if quota.present?
    elsif product_type == 'ProductFamily'
      product.products.each do |p|
        quota = Quota.where(user_id: user_id, time_period_id: time_period_id, value_type: value_type, product_id: p.id, product_type: 'Product').first
        errors.add(:base, "Product - #{p.name} has already taken") if quota.present?
      end
    end
  end
end
