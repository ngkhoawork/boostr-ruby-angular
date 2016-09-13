require 'rails_helper'

RSpec.describe DealContact, type: :model do
  context 'associations' do
    it { should belong_to(:contact) }
    it { should belong_to(:deal) }
  end
end
