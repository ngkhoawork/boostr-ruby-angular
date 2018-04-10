class UpdateCreatedFromValue < ActiveRecord::Migration
  def change
    Contact.where(created_from: 'false').update_all(created_from: nil)
    Contact.where(created_from: 'true').update_all(created_from: 'Web-Form Lead')

    Client.where(created_from: 'false').update_all(created_from: nil)
    Client.where(created_from: 'true').update_all(created_from: 'Web-Form Lead')

    Deal.where(created_from: 'false').update_all(created_from: nil)
    Deal.where(created_from: 'true').update_all(created_from: 'Web-Form Lead')
  end
end
