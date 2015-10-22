class Company < ActiveRecord::Base
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
  has_many :fields

  belongs_to :primary_contact, class_name: 'User'
  belongs_to :billing_contact, class_name: 'User'

  has_one :billing_address, as: :addressable, class_name: 'Address'
  has_one :physical_address, as: :addressable, class_name: 'Address'

  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :physical_address

  before_create :setup_defaults

  def setup_defaults
    client_type = fields.find_or_initialize_by(subject_type: 'Client', name: 'Client Type', value_type: 'Option', locked: true)
    setup_default_options(client_type, ['Advertiser', 'Agency'])

    fields.find_or_initialize_by(subject_type: 'Deal', name: 'Deal Type', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Deal', name: 'Deal Source', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Product', name: 'Pricing Type', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Product', name: 'Product Line', value_type: 'Option', locked: true)
    fields.find_or_initialize_by(subject_type: 'Product', name: 'Product Family', value_type: 'Option', locked: true)
  end

  def settings
    [
      { name: 'Deals', fields: fields.where(subject_type: 'Deal')},
      { name: 'Clients', fields: fields.where(subject_type: 'Client')},
      { name: 'Products', fields: fields.where(subject_type: 'Product')}
    ]
  end

  protected

  def setup_default_options(field, names)
    names.each do |name|
      field.options.find_or_initialize_by(name: name, company: self, locked: true)
    end
  end
end
