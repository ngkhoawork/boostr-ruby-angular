require 'rails_helper'

RSpec.describe ContactCfOption, type: :model do
  context 'associations' do
    it { should belong_to(:contact_cf_name) }
  end
end
