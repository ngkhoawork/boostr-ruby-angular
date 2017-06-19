class AccountDimension < ActiveRecord::Base
  belongs_to :client
  has_many :account_pipeline_facts, dependent: :destroy
  has_many :account_revenue_facts, dependent: :destroy
  belongs_to :holding_company
end
