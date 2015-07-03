class Company < ActiveRecord::Base
  has_many :users
  belongs_to :primary_contact, class_name: 'User'
  belongs_to :billing_contact, class_name: 'User'
end
