class AccountCf < ActiveRecord::Base
  include HasValidationsOnPercentageCfs

  belongs_to :company
  belongs_to :client

  before_save :fetch_company_id_from_client, on: :create

  def account_cf_names
    @account_cf_names ||= client&.company&.account_cf_names || AccountCfName.none
  end

  private

  def self.custom_field_names_assoc
    :account_cf_names
  end

  def fetch_company_id_from_client
    self.company_id ||= client&.company_id
  end
end
