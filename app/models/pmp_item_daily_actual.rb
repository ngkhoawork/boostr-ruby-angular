class PmpItemDailyActual < ActiveRecord::Base
  belongs_to :pmp_item, required: true

  validates :date, :price, :revenue, :impressions, :win_rate, :bids, presence: true

  scope :latest, -> { order('date DESC') }
end