class Pmp < ActiveRecord::Base
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id'
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :company
  belongs_to :deal

  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  has_many :pmp_members, dependent: :destroy
  has_many :pmp_items, dependent: :destroy
  has_many :pmp_item_daily_actuals, through: :pmp_items, dependent: :destroy

  validates :name, :start_date, :end_date, :curr_cd, presence: true

  scope :by_name, -> (name) { where('pmps.name ilike ?', "%#{name}%") if name.present? }
  scope :by_advertiser_name, -> (name) { joins(:advertiser).where('clients.name ilike ?', "%#{name}%") if name.present? }
  scope :by_agency_name, -> (name) { joins(:agency).where('clients.name ilike ?', "%#{name}%") if name.present? }
  scope :by_start_date, -> (start_date, end_date) { where(start_date: start_date..end_date) if (start_date && end_date).present? }

  before_create :set_budget_remaining_and_delivered
  
  def exchange_rate
    company.exchange_rate_for(currency: self.curr_cd)
  end

  def calculate_budgets!
    items = self.pmp_items.reload.to_a
    self.budget = items.map(&:budget).inject(0, &:+)
    self.budget_loc = items.map(&:budget_loc).inject(0, &:+)
    self.budget_delivered = items.map(&:budget_delivered).inject(0, &:+)
    self.budget_delivered_loc = items.map(&:budget_delivered_loc).inject(0, &:+)
    self.budget_remaining = items.map(&:budget_remaining).inject(0, &:+)
    self.budget_remaining_loc = items.map(&:budget_remaining_loc).inject(0, &:+)
    self.save!
  end

  private

  def set_budget_remaining_and_delivered
    if self.budget.present? && self.budget_loc.present?
      self.budget_remaining = self.budget
      self.budget_remaining_loc = self.budget_loc
      self.budget_delivered = 0
      self.budget_delivered_loc = 0
    end
  end
end