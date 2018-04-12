class AccountCf < ActiveRecord::Base
  belongs_to :company
  belongs_to :client

  before_save :fetch_company_id_from_client, on: :create

  private

  def fetch_company_id_from_client
    self.company_id ||= client&.company_id
  end
end
