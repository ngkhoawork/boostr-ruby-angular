class ClientContact < ActiveRecord::Base
  belongs_to :client, counter_cache: :contacts_count
  belongs_to :contact, required: true

  validates_uniqueness_of :client_id, scope: [:contact_id]

  scope :for_client, -> client_id { where(client_id: client_id, primary: false) if client_id.present? }
  scope :for_primary_client, -> client_id { where(client_id: client_id, primary: true) if client_id.present? }
  # scope :for_primary_client, -> client_id { Contact.joins("INNER JOIN client_contacts as cc ON cc.contact_id = contacts.id").where("cc.client_id = ? and cc.primary IS TRUE", client_id) if client_id.present? }

  after_destroy  do
  end
  def as_json(options = {})
    super(options.merge(include: {
            client: {
                    only: [:id, :name]
            }
    }))
  end
end
