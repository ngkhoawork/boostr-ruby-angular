class Activity < ActiveRecord::Base

  belongs_to :company
  belongs_to :user
  belongs_to :contact
  belongs_to :client
  belongs_to :deal
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'

  validates :company_id, presence: true

  after_create do
    if !deal_id.nil?
      deal = company.deals.find(deal_id)
      deal.update_attribute(:activity_updated_at, happened_at)
    elsif !client_id.nil?
      client = company.clients.find(client_id)
      client.update_attribute(:activity_updated_at, happened_at)
    end
    contact = company.contacts.find(contact_id)
    contact.update_attribute(:activity_updated_at, happened_at)
  end

  def as_json(options = {})
    super(options.merge(include: [:client, :deal, :contact, :creator]))
  end
end
