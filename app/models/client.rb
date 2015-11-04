class Client < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company

  has_many :client_members
  has_many :users, through: :client_members
  has_many :contacts
  has_many :revenue
  has_many :agency_deals, class_name: 'Deal', foreign_key: 'agency_id'
  has_many :advertiser_deals, class_name: 'Deal', foreign_key: 'advertiser_id'
  has_many :values, as: :subject

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address, :values

  validates :name, presence: true

  before_create :ensure_client_member

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

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def as_json(options = {})
    super(options.merge(include: [:address, values: { include: [:option], methods: [:value] }], methods: [:deals_count, :fields]))
  end

  def ensure_client_member
    return true if created_by.blank?
    return true if client_members.detect { |member| member.user_id == created_by }

    client_members.build(user_id: created_by, share: 0)
  end
end
