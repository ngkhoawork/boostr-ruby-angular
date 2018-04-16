class PmpItemDailyActual < ActiveRecord::Base
  attr_accessor :imported

  belongs_to :pmp_item, required: true
  belongs_to :advertiser, class_name: 'Client'

  validates :date, :ad_unit, presence: true
  validates :ad_requests, :impressions, :revenue_loc, :price, presence: true, numericality: true
  validates :win_rate, numericality: true, allow_nil: true

  scope :latest, -> { order('date DESC') }
  scope :oldest, -> { order('date ASC') }

  delegate :pmp, to: :pmp_item, allow_nil: true
  delegate :product, to: :pmp_item, allow_nil: true

  before_save :convert_currency
  before_save :set_default_values

  after_save do
    if not_imported?
      update_pmp_item
      update_pmp_end_date
    end
  end

  after_destroy do
    pmp_item.calculate!
  end

  def self.bulk_assign_advertiser(ssp_advertiser, client, user)
    if ssp_advertiser.present? && client.present? && user.present?
      pmp_item_daily_actuals = user.company.pmp_item_daily_actuals
                    .where(ssp_advertiser: ssp_advertiser, advertiser_id: nil).to_a
      pmp_item_daily_actuals.map(&:pmp_item).compact.map(&:ssp_id).compact.uniq.each do |ssp_id|
        SspAdvertiser.create_or_update(ssp_advertiser, client.id, ssp_id, user) 
      end
      user.company.pmp_item_daily_actuals
          .where(ssp_advertiser: ssp_advertiser, advertiser_id: nil)
          .update_all(advertiser_id: client.id)
      pmp_item_daily_actuals.map(&:id)
    end
  end

  def assign_advertiser!(client, user)
    if self.ssp_advertiser.present? 
      SspAdvertiser.create_or_update(self.ssp_advertiser, client.id, pmp_item&.ssp&.id, user) 
    end
    self.advertiser_id = client.id
    self.save!
  end

  private

  def set_default_values
    self.win_rate ||= ad_requests.to_f/impressions.to_f*100 rescue nil
  end

  def convert_currency
    if revenue_loc.present? && revenue_loc_changed? && pmp.present?
      self.revenue = revenue_loc / pmp.exchange_rate
    end
  end

  def update_pmp_item
    if pmp_item_id_changed? && pmp_item_id_was && old_pmp_item = PmpItem.find(pmp_item_id_was)
      old_pmp_item.calculate!
      pmp_item.calculate!
    elsif revenue_changed? || revenue_loc_changed?
      pmp_item.calculate_budgets!
      pmp_item.calculate_run_rates!
      pmp_item.save!
    elsif date_changed?
      pmp_item.calculate_run_rates!
      pmp_item.update_stopped_status!
      pmp_item.save!
    end
  end

  def update_pmp_end_date
    if date_changed?
      pmp.calculate_dates!
    end
  end

  def not_imported?
    !imported
  end
end