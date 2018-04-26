class PublisherCustomField < ActiveRecord::Base
  include HasValidationsOnPercentageCfs

  belongs_to :company, required: true
  belongs_to :publisher, required: true

  before_validation :fetch_company_id_from_publisher, on: :create

  def self.custom_field_names_assoc
    :publisher_custom_field_names
  end

  def publisher_custom_field_names
    @publisher_custom_field_names ||= publisher&.company&.publisher_custom_field_names || PublisherCustomFieldName.none
  end

  private

  def fetch_company_id_from_publisher
    self.company_id = publisher&.company_id
  end
end
