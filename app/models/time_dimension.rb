class TimeDimension < ActiveRecord::Base
  has_many :account_product_revenue_facts, dependent: :destroy
  has_many :account_product_pipeline_facts, dependent: :destroy
  has_many :advertiser_agency_revenue_facts, dependent: :destroy
  has_many :advertiser_agency_pipeline_facts, dependent: :destroy
  has_many :account_pipeline_facts, dependent: :destroy
  has_many :account_revenue_facts, dependent: :destroy

  scope :yearly, -> { where('days_length < ?', 360) }
  scope :by_dates, -> start_date, end_date { where(start_date: start_date, end_date: end_date) }
end
