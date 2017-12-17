class PmpItemDailyActual < ActiveRecord::Base
  attr_accessor :imported

  belongs_to :pmp_item, required: true
  belongs_to :product

  validates :date, :ad_unit, presence: true
  validates :bids, :impressions, :revenue_loc, :price, presence: true, numericality: true
  validates :render_rate, numericality: true, allow_nil: true

  scope :latest, -> { order('date DESC') }

  before_save :convert_currency
  before_save :set_default_values 
  after_save :update_pmp_item, if: :not_imported?
  after_save :update_pmp_end_date, if: :not_imported?
  after_destroy { pmp_item.calculate! }

  private

  def set_default_values
    self.win_rate ||= bids.to_f/impressions.to_f*100 rescue nil
  end

  def convert_currency
    if revenue_loc.present? && revenue_loc_changed? && pmp_item.present? && pmp_item.pmp.present?
      self.revenue = revenue_loc * pmp_item.pmp.exchange_rate
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
      pmp_item.pmp.calculate_end_date!
    end
  end

  def not_imported?
    !imported
  end
end