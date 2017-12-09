class PmpItemDailyActual < ActiveRecord::Base
  attr_accessor :imported

  belongs_to :pmp_item, required: true

  validates :date, :price, :revenue_loc, :revenue, :impressions, :win_rate, :bids, presence: true

  scope :latest, -> { order('date DESC') }

  before_validation :convert_currency
  after_save :update_pmp_item_budgets, if: :revenues_or_pmp_item_changed?
  after_destroy :update_pmp_item_budgets

  private

  def convert_currency
    if self.revenue_loc.present? && self.revenue_loc_changed?
      self.revenue = self.revenue_loc * self.pmp_item.pmp.exchange_rate
    end
  end

  def update_pmp_item_budgets
    if pmp_item_id_changed? && pmp_item_id_was && old_pmp_item = PmpItem.find(pmp_item_id_was)
      old_pmp_item.calculate!
    end
    self.pmp_item.calculate!
  end

  def revenues_or_pmp_item_changed?
    !self.imported && (revenue_changed? || revenue_loc_changed? || pmp_item_id_changed?)
  end
end