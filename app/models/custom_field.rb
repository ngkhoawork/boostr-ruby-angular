class CustomField < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :subject, polymorphic: true
end
