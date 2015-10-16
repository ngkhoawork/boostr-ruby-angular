require 'rails_helper'

RSpec.describe ClientMember, 'validation' do
  it { should validate_presence_of(:share) }
  it { should validate_presence_of(:values).with_message('Role must be assigned') }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:client_id) }
end

RSpec.describe ClientMember, 'association' do
  it { should belong_to(:client) }
  it { should belong_to(:user) }
end
