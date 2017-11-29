class PublisherCustomField < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :publisher, required: true

  before_validation :fetch_company_id_from_publisher, on: :create

  private

  def fetch_company_id_from_publisher
    self.company_id = publisher&.company_id
  end
end
