class CustomField < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :subject, polymorphic: true

  before_validation :set_company_id_by_subject

  private

  def set_company_id_by_subject
    self.company_id = subject.company_id if subject
  end
end
