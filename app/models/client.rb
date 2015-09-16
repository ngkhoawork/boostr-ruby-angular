class Client < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company

  has_many :client_members
  has_many :users, through: :client_members
  has_many :contacts
  has_many :revenue
  has_many :agency_deals, class_name: 'Deal', foreign_key: 'agency_id'
  has_many :advertiser_deals, class_name: 'Deal', foreign_key: 'advertiser_id'

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address

  validates :name, presence: true

  def deals_count
    advertiser_deals_count + agency_deals_count
  end

  def as_json(options = {})
    super(options.merge(include: [:address], methods: [:deals_count]))
  end
end
