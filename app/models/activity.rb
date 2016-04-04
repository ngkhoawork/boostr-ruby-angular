class Activity < ActiveRecord::Base

  belongs_to :company
  belongs_to :user
  belongs_to :contact
  belongs_to :client
  belongs_to :deal
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'

  validates :company_id, presence: true

end
