require 'rails_helper'

RSpec.describe ContactCf, type: :model do
  context 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:contact) }
  end
end
