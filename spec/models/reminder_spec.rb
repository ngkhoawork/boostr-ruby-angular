require 'rails_helper'

RSpec.describe Reminder, type: :model do
  let(:user)     { create :user }
  let(:reminder) { create :reminder }

  it 'creates the reminder' do
    expect(reminder.name).to eq(Reminder.last.name)
  end

  it 'allows to search users reminders' do
    reminder.user_id = user.id
    reminder.save
    expect(user.reminders).to eq([reminder])
  end
end
