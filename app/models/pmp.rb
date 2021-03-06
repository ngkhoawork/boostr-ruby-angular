class Pmp < ActiveRecord::Base
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id'
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :company
  belongs_to :deal
  belongs_to :ssp_advertiser

  attr_accessor :skip_callback

  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  has_many :pmp_members, dependent: :destroy
  has_many :users, through: :pmp_members, dependent: :destroy
  has_many :pmp_items, dependent: :destroy
  has_many :pmp_item_daily_actuals, through: :pmp_items, dependent: :destroy
  has_many :products, through: :pmp_items

  validates :name, presence: true, uniqueness: { scope: [:company_id], message: 'should be unique in scope of company.' }
  validates :start_date, :end_date, :curr_cd, presence: true

  scope :for_pmp_members, -> (user_ids) { joins(:pmp_members).where('pmp_members.user_id in (?)', user_ids) if user_ids}
  scope :by_name, -> (name) { where('pmps.name ilike ?', "%#{name}%") if name.present? }
  scope :by_advertiser_name, -> (name) { joins(:advertiser).where('clients.name ilike ?', "%#{name}%") if name.present? }
  scope :without_advertiser, -> { where(advertiser_id: nil) }
  scope :by_agency_name, -> (name) { joins(:agency).where('clients.name ilike ?', "%#{name}%") if name.present? }
  scope :by_start_date, -> (start_date, end_date) { where(start_date: start_date..end_date) if (start_date && end_date).present? }
  scope :for_time_period, -> (start_date, end_date) { where('pmps.start_date <= ? AND pmps.end_date >= ?', end_date, start_date) }
  scope :by_user, -> (user) { includes(:pmp_members).where('pmp_members.user_id = ?', user.id) }
  scope :without_advertiser, -> { where(advertiser_id: nil) }
  scope :no_match_advertiser, -> (ssp_advertiser_id) { where(ssp_advertiser_id: ssp_advertiser_id, advertiser_id: nil) }

  before_create :set_budget_remaining_and_delivered

  after_save do
    update_pmp_members_date
    update_revenue_fact_callback unless skip_callback
  end

  after_destroy :update_revenue_fact

  def update_revenue_fact_callback
    if start_date_changed? || end_date_changed?
      if start_date_was && end_date_was
        s_date = [start_date_was, start_date].min
        e_date = [end_date_was, end_date].max
      else
        s_date = start_date
        e_date = end_date
      end
      options = {
        start_date: s_date,
        end_date: e_date
      }
      Forecast::PmpRevenueCalcTriggerService.new(self, 'date', options).perform
    end
  end

  def update_revenue_fact
    Forecast::PmpRevenueCalcTriggerService.new(self, 'item', {}).perform
  end
  
  def self.calculate_dates(ids)
    Pmp.where(id: ids).find_each do |pmp|
      pmp.calculate_dates!
    end
  end

  def exchange_rate()
    company.exchange_rate_for(currency: curr_cd)
  end

  def calculate_budgets!
    items = pmp_items.reload.to_a
    self.budget = items.map(&:budget).compact.inject(0, &:+)
    self.budget_loc = items.map(&:budget_loc).compact.inject(0, &:+)
    self.budget_delivered = items.map(&:budget_delivered).compact.inject(0, &:+)
    self.budget_delivered_loc = items.map(&:budget_delivered_loc).compact.inject(0, &:+)
    self.budget_remaining = items.map(&:budget_remaining).compact.inject(0, &:+)
    self.budget_remaining_loc = items.map(&:budget_remaining_loc).compact.inject(0, &:+)
    self.save!
  end

  def calculate_dates!
    daily_actual_end_date = pmp_item_daily_actuals.maximum(:date)
    daily_actual_start_date = pmp_item_daily_actuals.minimum(:date)
    if daily_actual_end_date.present? && end_date < daily_actual_end_date
      self.end_date = daily_actual_end_date
    end
    if daily_actual_start_date.present? && start_date > daily_actual_start_date
      self.start_date = daily_actual_start_date
    end
    self.save!
  end

  def opened?
    start_date <= today && end_date >= today
  end

  def today
    Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
  end

  def assign_advertiser!(client)
    ssp_advertiser.update_attribute(:client_id, client.id) if ssp_advertiser.present?
    update_attribute(:advertiser_id, client.id)
  end

  private

  def set_budget_remaining_and_delivered
    if budget.present? && budget_loc.present?
      self.budget_remaining = budget
      self.budget_remaining_loc = budget_loc
      self.budget_delivered = 0
      self.budget_delivered_loc = 0
    end
  end

  def update_pmp_members_date
    if end_date_changed? && !pmp_members.empty?
      pmp_members.where(to_date: end_date_was).update_all(to_date: end_date)
    end
    if start_date_changed? && !pmp_members.empty?
      pmp_members.where(from_date: start_date_was).update_all(from_date: start_date)
    end
  end
end