class Pmp < ActiveRecord::Base
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id'
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :company
  belongs_to :deal

  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  has_many :pmp_members, dependent: :destroy
  has_many :pmp_items, dependent: :destroy
  has_many :pmp_item_daily_actuals, through: :pmp_items, dependent: :destroy

  validates :name, :budget, :budget_loc, :start_date, :end_date, :curr_cd, presence: true

  scope :by_name, -> (name) { where('pmps.name ilike ?', "%#{name}%") if name.present? }

  before_validation :convert_currency, on: :create

  private

  def convert_currency
    if self.budget.nil? && self.budget_loc.present? && self.curr_cd.present?
      self.budget = self.budget_loc * company.exchange_rate_for(currency: self.curr_cd) rescue nil
    end
  end
end