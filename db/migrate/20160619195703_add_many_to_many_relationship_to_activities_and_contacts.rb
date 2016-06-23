class AddManyToManyRelationshipToActivitiesAndContacts < ActiveRecord::Migration
  def up
    create_table :activities_contacts do |t|
      t.belongs_to :activity, index: true
      t.belongs_to :contact, index: true
    end

    activities = select_all("SELECT * FROM activities")
    activities.each do |activity|
      if not activity['contact_id']
        activity['contact_id'] = 'NULL'
      end
      insert("INSERT INTO activities_contacts (activity_id, contact_id) VALUES (#{activity['id']}, #{activity['contact_id']})")
    end

    remove_column :activities, :contact_id
  end

  def down
    add_column :activities, :contact_id, index: true

    associations = select_all("SELECT * FROM activities_contacts")
    associations.each do |assoc|
      if not assoc['contact_id']
        assoc['contact_id'] = 'NULL'
      end
      update("UPDATE activities SET contact_id = #{assoc['contact_id']} WHERE id = #{assoc['activity_id']}")
    end

    drop_table :activities_contacts
  end
end
