require 'rails_helper'

RSpec.describe Request, type: :model do
  context 'validations' do
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_length_of(:resolution).is_at_most(1000) }
  end

  context 'associations' do
    it { should belong_to(:requester) }
    it { should belong_to(:assignee) }
    it { should belong_to(:deal) }
    it { should belong_to(:requestable) }
    it { should belong_to(:company) }
  end
end
