require 'rails_helper'

RSpec.describe Reminder, type: :model do
  let(:user)     { create :user }
  let!(:reminder) { create(:reminder, remindable_id: 130, remindable_type: "Deal", user_id: user.id) }
  let(:unassigned_reminder) { create(:reminder, user_id: user.id, assigned: false) }

  context 'scopes' do
    context 'by_id' do
      it 'returns a reminder' do
        expect(Reminder.by_id(reminder.id, user.id).last).to eq(reminder)
      end
    end

    context 'user_reminders' do
      let!(:another_reminder) { create(:reminder, remindable_id: 133, remindable_type: "Client", user_id: user.id) }

      it 'returns all user\'s reminders' do
        expect(Reminder.user_reminders(user.id)).to eq([reminder, another_reminder])
      end
    end

    context 'by_remindable' do
      it 'find a reminder via remindable id and type' do
        expect(Reminder.by_remindable(user.id, reminder.remindable_id, reminder.remindable_type).last).to eq(reminder)
      end
    end
  end

  it 'creates the reminder' do
    expect(Reminder.last.name).to eq(reminder.name)
  end

  it 'allows to search users reminders' do
    reminder.user_id = user.id
    reminder.save
    expect(user.reminders).to eq([reminder])
  end

  it 'allows to skip validation for remindable id and type if unassigned' do
    expect(unassigned_reminder).to be_persisted
  end

end
