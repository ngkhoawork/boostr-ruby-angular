class GenerateClientContactAssociations < ActiveRecord::Migration
  def change
    Contact.where.not(client_id: nil).each do |contact|
      rel = ClientContact.find_or_create_by(
        contact_id: contact.id,
        client_id: contact.client_id
      )
      rel.primary = true
      rel.save
    end
  end
end
