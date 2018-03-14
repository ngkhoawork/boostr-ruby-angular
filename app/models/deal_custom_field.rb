class DealCustomField < ActiveRecord::Base
  belongs_to :company
  belongs_to :deal

  before_save :fetch_company_id_from_deal, on: :create

  private

  def fetch_company_id_from_deal
    self.company_id ||= deal&.company_id
  end
end
