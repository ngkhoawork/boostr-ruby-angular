class Company < ActiveRecord::Base
  has_many :users
  belongs_to :primary_contact, class_name: 'User'
  belongs_to :billing_contact, class_name: 'User'

  has_many :contracts
  has_many :licenses, through: :contracts

  accepts_nested_attributes_for :contracts
end
