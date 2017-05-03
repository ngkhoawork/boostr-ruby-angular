namespace :contacts do
  desc 'Update activity_updated_at for contacts'
  task update_activity_updated_at: :environment do
    Contact.find_each do |contact|
      latest_happened_activity = contact.latest_happened_activity

      contact.update(activity_updated_at: latest_happened_activity.first.happened_at) if latest_happened_activity.any?
    end
  end
end
