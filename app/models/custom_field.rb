class CustomField < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :subject, polymorphic: true

  before_validation :set_company_id_by_subject

  def self.allowed_attr_names(company, subject_type)
    company.custom_field_names.for_model(subject_type).map(&:field_name)
  end

  def allowed_attr_names
    self.class.allowed_attr_names(company, subject_type)
  end

  private

  def set_company_id_by_subject
    self.company_id = subject.company_id if subject
  end
end
