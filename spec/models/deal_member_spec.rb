require 'rails_helper'

RSpec.describe DealMember, 'validation' do
  it { should validate_presence_of(:share) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:deal_id) }
end

RSpec.describe DealMember, 'association' do
  it { should belong_to(:deal) }
  it { should belong_to(:user) }
end
