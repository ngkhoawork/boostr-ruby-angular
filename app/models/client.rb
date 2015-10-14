class Client < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :client_type

  has_many :client_members
  has_many :users, through: :client_members
  has_many :contacts
  has_many :revenue
  has_many :agency_deals, class_name: 'Deal', foreign_key: 'agency_id'
  has_many :advertiser_deals, class_name: 'Deal', foreign_key: 'advertiser_id'

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address

  validates :name, presence: true

  def self.to_csv
    attributes = {
      id: 'Client ID',
      name: 'Name'
    }

    CSV.generate(headers: true) do |csv|
      csv << attributes.values

      all.each do |client|
        csv << attributes.map{ |key, value| client.send(key) }
      end
    end
  end

  def deals_count
    advertiser_deals_count + agency_deals_count
  end

  def as_json(options = {})
    super(options.merge(include: [:address, :client_type], methods: [:deals_count]))
  end
end
