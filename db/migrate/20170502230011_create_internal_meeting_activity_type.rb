class CreateInternalMeetingActivityType < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.activity_types.create(
        name: 'Internal Meeting',
        action: 'had internal meeting with',
        icon: '/assets/icons/internal-meeting.png'
      )
    end
  end
end
