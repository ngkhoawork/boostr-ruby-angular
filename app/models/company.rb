class Company < ActiveRecord::Base
  include CustomValues

  has_many :users
  has_many :clients
  has_many :contacts, inverse_of: :company
  has_many :revenues
  has_many :deals
  has_many :stages
  has_many :products
  has_many :teams
  has_many :time_periods
  has_many :quotas
  has_many :client_types

  belongs_to :primary_contact, class_name: 'User'
  belongs_to :billing_contact, class_name: 'User'

  has_one :billing_address, as: :addressable, class_name: 'Address'
  has_one :physical_address, as: :addressable, class_name: 'Address'

  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :physical_address

  before_create :setup_defaults

  protected

  def setup_defaults
    client_types.build([{name: 'Advertiser'}, {name: 'Agency'}])
  end
end
