class Company < ActiveRecord::Base
  has_many :users
  belongs_to :primary_contact, class_name: 'User'
  belongs_to :billing_contact, class_name: 'User'

  has_many :contracts
  has_many :licenses, through: :contracts

  has_one :billing_address, as: :addressable, class_name: 'Address'
  has_one :physical_address, as: :addressable, class_name: 'Address'

  accepts_nested_attributes_for :contracts
  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :physical_address
end
