class EalertCustomField < ActiveRecord::Base
  belongs_to :company
  belongs_to :ealert
  belongs_to :subject, polymorphic: true
end
