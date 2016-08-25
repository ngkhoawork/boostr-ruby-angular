class AssignClientTypeIdsToAllClients < ActiveRecord::Migration
  def change
    companies = Company.all
    companies.each do |company|
      client_type_field = company.fields.where(subject_type: "Client", name: "Client Type").first
      company.clients.each do |client|
        client_type_value = client.values.where(field_id: client_type_field.id).first
        if client_type_value
          client.update_columns(client_type_id: client_type_value.option_id)
        end
      end
    end
  end
end
