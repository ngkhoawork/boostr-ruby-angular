class ExchangeRate < ActiveRecord::Base
  belongs_to :company
  belongs_to :currency

  validates :rate, :company_id, :currency_id, :start_date, :end_date, presence: true
  validate :not_overlap

  default_scope { order('end_date DESC') }

  scope :overlaps, -> (start_date, end_date) do
    where "((start_date <= ?) and (end_date >= ?))", end_date, start_date
  end

  scope :for_currency, -> (company_id, currency_id) do
    where company_id: company_id, currency_id: currency_id
  end

  def not_overlap
    return unless (company_id && currency_id && start_date && end_date)
    errors.add(:start_date, "overlaps with existing #{currency.curr_cd} exchange rate") if overlaps?
    errors.add(:end_date, "overlaps with existing #{currency.curr_cd} exchange rate") if overlaps?
  end

  def overlaps?
    overlaps.exists?
  end

  def overlaps
    siblings.overlaps start_date, end_date
  end

  private

  def siblings
    ExchangeRate.for_currency(company_id, currency_id).where('id != ?', id || -1)
  end
end
