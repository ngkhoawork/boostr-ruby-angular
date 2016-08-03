require 'rails_helper'

RSpec.describe Reminder, type: :model do
  let(:reminder) { create :reminder }

  it 'creates the reminder' do
    expect(reminder.name).to eq(Reminder.last.name)
  end
end
