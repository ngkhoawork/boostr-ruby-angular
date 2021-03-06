class ClientContact < ActiveRecord::Base
  belongs_to :client, counter_cache: :contacts_count
  belongs_to :contact, required: true
  belongs_to :account_dimension, foreign_key: :client_id

  validates_uniqueness_of :client_id, scope: [:contact_id]

  scope :for_client, -> client_id { where(client_id: client_id, primary: false) if client_id.present? }
  scope :for_primary_client, -> client_id { where(client_id: client_id, primary: true) if client_id.present? }
  # scope :for_primary_client, -> client_id { Contact.joins("INNER JOIN client_contacts as cc ON cc.contact_id = contacts.id").where("cc.client_id = ? and cc.primary IS TRUE", client_id) if client_id.present? }

  delegate :name, to: :account_dimension, prefix: true

  after_save do
    contact.update_pg_search_document
  end

  after_destroy do
    contact.update_pg_search_document unless self.destroyed_by_association
  end

  def as_json(options = {})
    super(options.deep_merge(include: {
            client: {
                    only: [:id, :name]
            }
    }))
  end

  def unassign_contact
    contact.update(client_id: nil) if contact.clients.ids == [client_id]
  end
end
