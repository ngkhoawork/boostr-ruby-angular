class DealCustomField < ActiveRecord::Base
  include HasValidationsOnPercentageCfs

  SAFE_COLUMNS = columns.map(&:name).map(&:to_sym)

  belongs_to :company
  belongs_to :deal

  before_save :fetch_company_id_from_deal, on: :create

  def deal_custom_field_names
    @deal_custom_field_names ||= deal&.company&.deal_custom_field_names || DealCustomFieldName.none
  end

  private

  def self.custom_field_names_assoc
    :deal_custom_field_names
  end

  def fetch_company_id_from_deal
    self.company_id ||= deal&.company_id
  end
end
