class SspAdvertiser < ActiveRecord::Base
  belongs_to :ssp
  belongs_to :company
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by

  validates :name, presence: true
end