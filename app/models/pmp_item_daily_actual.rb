class PmpItemDailyActual < ActiveRecord::Base
  attr_accessor :imported

  belongs_to :pmp_item, required: true
  belongs_to :product

  validates :date, :ad_unit, presence: true
  validates :bids, :impressions, :revenue_loc, :price, presence: true, numericality: true
  validates :render_rate, numericality: true, allow_nil: true

  scope :latest, -> { order('date DESC') }

  delegate :pmp, to: :pmp_item, allow_nil: true

  before_save :convert_currency
  before_save :set_default_values

  after_save do
    if not_imported?
      update_pmp_item
      update_pmp_end_date
      update_revenue_fact_callback
    end
  end

  after_destroy do
    pmp_item.calculate!
    update_revenue_fact
  end

  def update_revenue_fact_callback
    if pmp_item_id_changed? || revenue_changed? || revenue_loc_changed?
      options = { products: [product] }
    elsif product_id_changed?
      product_was = Product.find_by_id(product_id_was) if product_id_was
      options = { products: [product, product_was] }
    end
    Forecast::PmpRevenueCalcTriggerService.new(pmp, 'product', options).perform if options.present?
  end

  def update_revenue_fact
    Forecast::PmpRevenueCalcTriggerService.new(pmp, 'product', { products: [product] }).perform
  end

  private

  def set_default_values
    self.win_rate ||= bids.to_f/impressions.to_f*100 rescue nil
  end

  def convert_currency
    if revenue_loc.present? && revenue_loc_changed? && pmp.present?
      self.revenue = revenue_loc * pmp.exchange_rate
    end
  end

  def update_pmp_item
    if pmp_item_id_changed? && pmp_item_id_was && old_pmp_item = PmpItem.find(pmp_item_id_was)
      old_pmp_item.calculate!
      pmp_item.calculate!
    elsif revenue_changed? || revenue_loc_changed?
      pmp_item.calculate!
    elsif date_changed?
      pmp_item.calculate_run_rates!
      pmp_item.save!
    end
  end

  def update_pmp_end_date
    if date_changed?
      pmp.calculate_end_date!
    end
  end

  def not_imported?
    !imported
  end
end